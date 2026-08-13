--幻奏の音女スコア
-- 效果：
-- ①：自己的「幻奏」怪兽和对方怪兽进行战斗的伤害计算时，把这张卡从手卡送去墓地才能发动。那只对方怪兽的攻击力·守备力直到回合结束时变成0。
function c41767843.initial_effect(c)
	-- ①：自己的「幻奏」怪兽和对方怪兽进行战斗的伤害计算时，把这张卡从手卡送去墓地才能发动。那只对方怪兽的攻击力·守备力直到回合结束时变成0。
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
-- 判定是否满足发动条件：伤害计算时存在我方「幻奏」怪兽与对方怪兽进行战斗，且对方怪兽的攻击力或守备力至少一项大于0；若攻击者为对方怪兽则先交换，确保以我方「幻奏」怪兽为判定对象。
function c41767843.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的被攻击怪兽（攻击对象）。
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if a:IsControler(1-tp) then a,d=d,a end
	return a:IsSetCard(0x9b) and a:IsRelateToBattle() and (d:GetAttack()>0 or d:GetDefense()>0)
end
-- 代价判定与执行：先检查此卡是否可作为代价从手卡送去墓地，若可以则将其从手卡送去墓地作为发动代价。
function c41767843.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 执行代价操作：将此卡从手卡送去墓地，作为发动效果的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果处理：根据攻击方确定本次战斗中的对方怪兽（若攻击方为对方则取攻击者，否则取攻击对象），若该怪兽仍与战斗相关且不是里侧表示，则令其攻击力和守备力直到回合结束时变为0。
function c41767843.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的被攻击怪兽（攻击对象）。
	local d=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then d=a end
	if not d:IsRelateToBattle() or d:IsFacedown() then return end
	-- 那只对方怪兽的攻击力·守备力直到回合结束时变成0。
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
