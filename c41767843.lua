--幻奏の音女スコア
-- 效果：
-- ①：自己的「幻奏」怪兽和对方怪兽进行战斗的伤害计算时，把这张卡从手卡送去墓地才能发动。那只对方怪兽的攻击力·守备力直到回合结束时变成0。
function c41767843.initial_effect(c)
	-- 效果原文内容：①：自己的「幻奏」怪兽和对方怪兽进行战斗的伤害计算时，把这张卡从手卡送去墓地才能发动。那只对方怪兽的攻击力·守备力直到回合结束时变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41767843,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c41767843.condition)
	e1:SetCost(c41767843.cost)
	e1:SetOperation(c41767843.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断是否满足发动条件，即攻击怪兽是幻奏卡组且参与了战斗且对方怪兽攻击力或守备力大于0
function c41767843.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 规则层面作用：获取本次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if a:IsControler(1-tp) then a,d=d,a end
	return a:IsSetCard(0x9b) and a:IsRelateToBattle() and (d:GetAttack()>0 or d:GetDefense()>0)
end
-- 规则层面作用：检查是否满足发动代价，即是否能将此卡送入墓地作为代价
function c41767843.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 规则层面作用：将此卡送入墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 规则层面作用：执行效果，将对方怪兽的攻击力和守备力在本回合结束前设为0
function c41767843.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 规则层面作用：获取本次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then d=a end
	if not d:IsRelateToBattle() or d:IsFacedown() then return end
	-- 效果原文内容：那只对方怪兽的攻击力·守备力直到回合结束时变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(0)
	d:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
	d:RegisterEffect(e2)
end
