--究極伝導恐獣
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把2只恐龙族怪兽除外的场合可以特殊召唤。
-- ①：1回合1次，自己·对方的主要阶段才能发动。选自己的手卡·场上1只怪兽破坏，对方场上的表侧表示怪兽全部变成里侧守备表示。
-- ②：这张卡可以向对方怪兽全部各作1次攻击。
-- ③：这张卡向守备表示怪兽攻击的伤害步骤开始时才能发动。给与对方1000伤害，那只守备表示怪兽送去墓地。
function c18940556.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己·对方的主要阶段才能发动。选自己的手卡·场上1只怪兽破坏，对方场上的表侧表示怪兽全部变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c18940556.sprcon)
	e1:SetTarget(c18940556.sprtg)
	e1:SetOperation(c18940556.sprop)
	c:RegisterEffect(e1)
	-- ②：这张卡可以向对方怪兽全部各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18940556,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(c18940556.descon)
	e2:SetTarget(c18940556.destg)
	e2:SetOperation(c18940556.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡向守备表示怪兽攻击的伤害步骤开始时才能发动。给与对方1000伤害，那只守备表示怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 从自己墓地把2只恐龙族怪兽除外的场合可以特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(18940556,1))
	e4:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetTarget(c18940556.tgtg)
	e4:SetOperation(c18940556.tgop)
	c:RegisterEffect(e4)
end
-- 过滤函数，检查以玩家来看的墓地是否存在至少2张满足条件的恐龙族怪兽（可除外）
function c18940556.sprfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤条件函数，检查玩家是否满足特殊召唤条件（场上存在空位且墓地存在2只恐龙族怪兽）
function c18940556.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在至少2只恐龙族怪兽
		and Duel.IsExistingMatchingCard(c18940556.sprfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 特殊召唤目标函数，选择2只恐龙族怪兽从墓地除外
function c18940556.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家墓地所有恐龙族怪兽
	local g=Duel.GetMatchingGroup(c18940556.sprfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的2只恐龙族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤操作函数，将选中的2只恐龙族怪兽除外
function c18940556.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤原因除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 效果发动条件函数，检查当前是否为主阶段
function c18940556.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主阶段1或主阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤函数，检查以玩家来看的对方场上是否存在至少1张表侧表示且可变为里侧守备表示的怪兽
function c18940556.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果目标函数，检查是否满足发动条件（手牌或场上存在怪兽，对方场上存在可变为里侧守备表示的怪兽）
function c18940556.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌或场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,TYPE_MONSTER)
		-- 检查对方场上是否存在至少1张表侧表示且可变为里侧守备表示的怪兽
		and Duel.IsExistingMatchingCard(c18940556.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c18940556.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，确定要破坏的怪兽数量为1张
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	-- 设置操作信息，确定要改变表示形式的怪兽数量为对方场上的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果操作函数，选择1只怪兽破坏，然后将对方场上所有表侧表示怪兽变为里侧守备表示
function c18940556.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择玩家手牌或场上的1只怪兽
	local g1=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,TYPE_MONSTER)
	-- 判断是否成功破坏了怪兽
	if g1:GetCount()>0 and Duel.Destroy(g1,REASON_EFFECT)~=0 then
		-- 获取对方场上所有表侧表示的怪兽
		local g2=Duel.GetMatchingGroup(c18940556.posfilter,tp,0,LOCATION_MZONE,nil)
		if g2:GetCount()>0 then
			-- 将对方场上所有表侧表示怪兽变为里侧守备表示
			Duel.ChangePosition(g2,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 触发效果目标函数，检查是否满足发动条件（攻击怪兽为自身，攻击目标为守备表示怪兽）
function c18940556.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 检查攻击怪兽是否为自身，攻击目标是否存在且为守备表示
	if chk==0 then return Duel.GetAttacker()==e:GetHandler() and d and d:IsDefensePos() end
	-- 设置操作信息，确定要造成1000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	-- 设置操作信息，确定要将攻击目标怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,d,1,0,0)
end
-- 触发效果操作函数，对攻击目标造成1000伤害并将其送去墓地
function c18940556.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功造成伤害
	if Duel.Damage(1-tp,1000,REASON_EFFECT)~=0 then
		-- 获取攻击目标怪兽
		local d=Duel.GetAttackTarget()
		if d:IsRelateToBattle() and d:IsDefensePos() then
			-- 将攻击目标怪兽送去墓地
			Duel.SendtoGrave(d,REASON_EFFECT)
		end
	end
end
