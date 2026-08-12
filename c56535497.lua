--バーサーキング
-- 效果：
-- 1回合1次，选择场上表侧表示存在的2只兽族怪兽才能发动。直到那个回合的结束阶段时，选择的1只怪兽的攻击力变成一半，另1只怪兽的攻击力上升那个数值。这个效果在自己的主要阶段时以及对方的战斗阶段时才能发动。
function c56535497.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，选择场上表侧表示存在的2只兽族怪兽才能发动。直到那个回合的结束阶段时，选择的1只怪兽的攻击力变成一半，另1只怪兽的攻击力上升那个数值。这个效果在自己的主要阶段时以及对方的战斗阶段时才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56535497,1))  --"攻击变化"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1)
	e2:SetCondition(c56535497.condition)
	e2:SetTarget(c56535497.target)
	e2:SetOperation(c56535497.operation)
	c:RegisterEffect(e2)
end
-- 判定该效果是否在自己的主要阶段或对方的战斗阶段（且非伤害计算后）发动
function c56535497.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 若当前是自己的回合，则判定是否处于主要阶段1或主要阶段2
	if Duel.GetTurnPlayer()==tp then return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
	-- 若当前是对方的回合，则判定是否处于战斗阶段，且非伤害计算后
	else return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp) end
end
-- 过滤场上表侧表示存在且可以作为效果对象的兽族怪兽
function c56535497.filter(c,e)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsCanBeEffectTarget(e)
end
-- 过滤场上表侧表示存在且攻击力在1以上的怪兽
function c56535497.atkfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(1)
end
-- 检查选出的怪兽组中是否至少包含1只攻击力在1以上的怪兽
function c56535497.gcheck(g)
	return g:IsExists(c56535497.atkfilter,1,nil)
end
-- 效果发动的靶向处理，检查并选择场上2只表侧表示的兽族怪兽作为对象，且其中至少1只攻击力在1以上
function c56535497.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取场上所有满足条件的表侧表示兽族怪兽
	local g=Duel.GetMatchingGroup(c56535497.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return #g>=2 and g:IsExists(c56535497.atkfilter,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,c56535497.gcheck,false,2,2)
	-- 将选定的2只怪兽设置为效果的对象
	Duel.SetTargetCard(sg)
end
-- 效果处理，使其中1只怪兽的攻击力变成一半，另1只怪兽的攻击力上升那个数值
function c56535497.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在连锁处理时仍留在场上且仍是该效果对象的怪兽组
	local g=Duel.GetTargetsRelateToChain()
	if #g<2 then return end
	-- 提示玩家选择哪一只怪兽的攻击力要变成一半
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(56535497,2))  --"请选择攻击力变成一半的怪兽"
	local tc1=g:FilterSelect(tp,c56535497.atkfilter,1,1,nil):GetFirst()
	if not tc1 then return end
	local tc2=(g-tc1):GetFirst()
	local atk=math.ceil(tc1:GetAttack()/2)
	-- 直到那个回合的结束阶段时，选择的1只怪兽的攻击力变成一半
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	if tc1:RegisterEffect(e1) and tc2 and tc2:IsFaceup() then
		-- 另1只怪兽的攻击力上升那个数值
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc2:RegisterEffect(e2)
	end
end
