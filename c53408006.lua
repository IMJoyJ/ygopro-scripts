--ジェム・マーチャント
-- 效果：
-- 自己场上表侧表示存在的地属性的通常怪兽进行战斗的伤害步骤时可以把这张卡从手卡送去墓地，那只怪兽的攻击力·守备力直到这个回合的结束阶段时上升1000。
function c53408006.initial_effect(c)
	-- 自己场上表侧表示存在的地属性的通常怪兽进行战斗的伤害步骤时可以把这张卡从手卡送去墓地，那只怪兽的攻击力·守备力直到这个回合的结束阶段时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetDescription(aux.Stringid(53408006,0))  --"攻守上升"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c53408006.condition)
	e1:SetCost(c53408006.cost)
	e1:SetOperation(c53408006.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：判断怪兽是否为地属性且为通常怪兽，用于筛选符合条件的战斗怪兽。
function c53408006.filter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_NORMAL)
end
-- 发动条件：仅在伤害步骤且尚未进行伤害计算时，若自己场上表侧表示的地属性通常怪兽（攻击怪兽或攻击对象）正参与本次战斗，则满足发动条件。
function c53408006.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于确认是否处于伤害步骤。
	local phase=Duel.GetCurrentPhase()
	-- 如果当前不是伤害步骤，或已经进行过伤害计算，则不能发动，返回false。
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取攻击怪兽，用于后续判断其是否为我方场上的地属性通常怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽（攻击对象），若不存在则为nil。
	local d=Duel.GetAttackTarget()
	return (a:IsControler(tp) and c53408006.filter(a) and a:IsRelateToBattle())
		or (d and d:IsControler(tp) and d:IsFaceup() and c53408006.filter(d) and d:IsRelateToBattle())
end
-- 代价判定与执行：确认这张卡可以作为代价从手卡送去墓地；若可以，则将其送去墓地作为发动代价。
function c53408006.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把这张卡从手卡送去墓地，作为发动效果的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果处理：确定要提升能力值的怪兽（根据当前回合玩家选择攻击怪兽或攻击对象），若该怪兽仍与本次战斗相关，则使其攻击力·守备力直到结束阶段各上升1000。
function c53408006.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽，作为默认的效果目标候选。
	local a=Duel.GetAttacker()
	-- 若当前回合玩家不是本卡控制者，说明我方怪兽是被攻击方，则将目标改为攻击对象（被攻击的怪兽）。
	if Duel.GetTurnPlayer()~=tp then a=Duel.GetAttackTarget() end
	if not a:IsRelateToBattle() then return end
	-- 那只怪兽的攻击力直到这个回合的结束阶段时上升1000。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1000)
	a:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	a:RegisterEffect(e2)
end
