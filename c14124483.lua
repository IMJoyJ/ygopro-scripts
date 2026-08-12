--E・HERO オネスティ・ネオス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，对方回合也能发动。
-- ①：把这张卡从手卡丢弃，以场上1只「英雄」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升2500。
-- ②：从手卡丢弃1只「英雄」怪兽才能发动。这张卡的攻击力直到回合结束时上升丢弃的怪兽的攻击力数值。
function c14124483.initial_effect(c)
	-- ①：把这张卡从手卡丢弃，以场上1只「英雄」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升2500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14124483,0))  --"「英雄」怪兽攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,14124483)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c14124483.atkcost1)
	e1:SetTarget(c14124483.atktg)
	e1:SetOperation(c14124483.atkop1)
	c:RegisterEffect(e1)
	-- ②：从手卡丢弃1只「英雄」怪兽才能发动。这张卡的攻击力直到回合结束时上升丢弃的怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14124483,1))  --"丢弃手卡上升攻击力"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1,14124484)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e2:SetCondition(aux.dscon)
	e2:SetTarget(c14124483.atkcost2)
	e2:SetOperation(c14124483.atkop2)
	c:RegisterEffect(e2)
end
-- 效果发动时的处理函数，用于判断是否满足发动条件。
function c14124483.atkcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身从手牌丢入墓地作为效果的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 用于筛选场上满足条件的「英雄」怪兽的过滤函数。
function c14124483.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8)
end
-- 效果发动时选择目标的处理函数，用于选择场上的一只「英雄」怪兽。
function c14124483.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c14124483.atkfilter(chkc) end
	-- 检查场上是否存在满足条件的「英雄」怪兽作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c14124483.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择场上满足条件的「英雄」怪兽作为效果对象。
	Duel.SelectTarget(tp,c14124483.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果发动时的处理函数，用于执行效果内容。
function c14124483.atkop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽的攻击力上升2500点，持续到回合结束。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 用于筛选手牌中满足条件的「英雄」怪兽的过滤函数。
function c14124483.costfilter(c)
	return c:IsSetCard(0x8) and c:GetAttack()>0 and c:IsDiscardable()
end
-- 效果发动时的处理函数，用于判断是否满足发动条件并选择丢弃的怪兽。
function c14124483.atkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的「英雄」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c14124483.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	-- 选择手牌中满足条件的「英雄」怪兽作为丢弃对象。
	local g=Duel.SelectMatchingCard(tp,c14124483.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	-- 将选择的怪兽从手牌丢入墓地作为效果的代价。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果发动时的处理函数，用于执行效果内容。
function c14124483.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local atk=tc:GetAttack()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 使自身攻击力上升所丢弃怪兽的攻击力数值，持续到回合结束。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
