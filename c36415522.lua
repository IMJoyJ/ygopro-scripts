--EMピンチヘルパー
-- 效果：
-- ①：1回合1次，对方怪兽的直接攻击宣言时才能把这个效果发动。那次攻击无效，从卡组把1只「娱乐伙伴」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：自己怪兽和对方怪兽进行战斗的攻击宣言时，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。那次战斗发生的对自己的战斗伤害变成0。
function c36415522.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，对方怪兽的直接攻击宣言时才能把这个效果发动。那次攻击无效，从卡组把1只「娱乐伙伴」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c36415522.spcon)
	e2:SetTarget(c36415522.sptg)
	e2:SetOperation(c36415522.spop)
	c:RegisterEffect(e2)
	-- ②：自己怪兽和对方怪兽进行战斗的攻击宣言时，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。那次战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c36415522.atkcost)
	e3:SetTarget(c36415522.atktg)
	e3:SetOperation(c36415522.atkop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中属于「娱乐伙伴」字段且满足当前效果特殊召唤条件的怪兽。
function c36415522.filter(c,e,tp)
	return c:IsSetCard(0x9f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件：仅在对方怪兽的直接攻击宣言时才能发动。
function c36415522.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击者是对方怪兽且攻击目标为nil（即直接攻击）。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果①的目标判定：检查己方主要怪兽区是否有空位，且卡组中存在符合条件的「娱乐伙伴」怪兽。
function c36415522.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足filter条件的「娱乐伙伴」怪兽。
		and Duel.IsExistingMatchingCard(c36415522.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：效果包含从卡组特殊召唤1只怪兽，供后续相关卡片的检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果①：无效对方的直接攻击，从卡组选1只「娱乐伙伴」怪兽特殊召唤，并使那只怪兽效果无效化。
function c36415522.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若攻击无效化失败（攻击已被其他效果无效或无法无效），则不再进行后续特殊召唤处理。
	if not Duel.NegateAttack() then return end
	-- 若己方没有可用的主要怪兽区空格，则无法特殊召唤，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组中筛选出1张符合条件的「娱乐伙伴」怪兽，由选择者确定。
	local g=Duel.SelectMatchingCard(tp,c36415522.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功通过SpecialSummonStep将选中的怪兽以表侧表示特殊召唤，则为其附加无效化效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤处理，将之前暂定的特殊召唤正式生效。
	Duel.SpecialSummonComplete()
end
-- 效果②的发动代价：将魔法陷阱区表侧表示的这张卡送去墓地，并判断其能否作为代价。
function c36415522.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsStatus(STATUS_EFFECT_ENABLED) and c:IsAbleToGraveAsCost() end
	-- 以规则代价（COST）的形式将这张卡送去墓地。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 效果②的发动对象选择：确认正在战斗的双方怪兽属于不同控制者，并将对方那只怪兽作为后续判定对象。
function c36415522.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击宣言的怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽（直接攻击时为nil）。
	local d=Duel.GetAttackTarget()
	if chk==0 then return d and a:GetControler()~=d:GetControler() end
	if a:IsControler(1-tp) then a=d end
	e:SetLabelObject(a)
end
-- 处理效果②：为己方玩家附加在这只对方怪兽参与战斗时使战斗伤害变为0的效果。
function c36415522.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 那次战斗发生的对自己的战斗伤害变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(1)
		e1:SetCondition(c36415522.damcon)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetLabelObject(tc)
		-- 将避免战斗伤害的效果注册到游戏中，持续至伤害计算阶段结束。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判定避免战斗伤害效果是否应该生效：只要记录的那只怪兽是当前战斗的攻击者或被攻击者之一即生效。
function c36415522.damcon(e)
	local tc=e:GetLabelObject()
	-- 判断标签对象是否等于当前攻击者或被攻击者。
	return tc==Duel.GetAttacker() or tc==Duel.GetAttackTarget()
end
