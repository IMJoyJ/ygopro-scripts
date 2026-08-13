--E・HERO オネスティ・ネオス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，对方回合也能发动。
-- ①：把这张卡从手卡丢弃，以场上1只「英雄」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升2500。
-- ②：从手卡丢弃1只「英雄」怪兽才能发动。这张卡的攻击力直到回合结束时上升丢弃的怪兽的攻击力数值。
function c14124483.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次，对方回合也能发动。①：把这张卡从手卡丢弃，以场上1只「英雄」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升2500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14124483,0))  --"「英雄」怪兽攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,14124483)
	-- 设置①效果的发动条件：当前不是伤害步骤或伤害计算尚未进行，即伤害步骤中只能在伤害计算前发动，避免在伤害计算时发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c14124483.atkcost1)
	e1:SetTarget(c14124483.atktg)
	e1:SetOperation(c14124483.atkop1)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次，对方回合也能发动。②：从手卡丢弃1只「英雄」怪兽才能发动。这张卡的攻击力直到回合结束时上升丢弃的怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14124483,1))  --"丢弃手卡上升攻击力"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1,14124484)
	-- 设置②效果的发动条件：当前不是伤害步骤或伤害计算尚未进行，即伤害步骤中只能在伤害计算前发动，避免在伤害计算时发动。
	e2:SetCondition(aux.dscon)
	e2:SetTarget(c14124483.atkcost2)
	e2:SetOperation(c14124483.atkop2)
	c:RegisterEffect(e2)
end
-- ①效果的cost：从手卡丢弃这张卡作为发动代价。chk==0时判定该卡是否可以丢弃，实际执行时将其从手卡送去墓地。
function c14124483.atkcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 以「代价+丢弃」的原因将这张卡从手卡送入墓地，完成①效果的cost。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤函数：筛选表侧表示且属于「英雄」（0x8）字段的怪兽，用于①效果选择对象。
function c14124483.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8)
end
-- ①效果的取对象处理：chkc时验证指定对象是否合法；chk==0时检查是否存在合法对象；存在则用SelectTarget选择场上1只表侧表示「英雄」怪兽作为对象。
function c14124483.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c14124483.atkfilter(chkc) end
	-- 检查场上是否有至少1只表侧表示「英雄」怪兽可以成为效果对象，作为①效果发动的条件。
	if chk==0 then return Duel.IsExistingTarget(c14124483.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择效果对象的提示信息（HINTMSG_TARGET），用于取对象时的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择场上1只表侧表示「英雄」怪兽作为①效果的对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,c14124483.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ①效果处理：取得对象怪兽，若其仍与效果关联且表侧表示，则给它赋予攻击力上升2500的持续效果，持续到回合结束。
function c14124483.atkop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果选择的对象怪兽（当前连锁的第一个目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时上升2500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数：筛选手牌中属于「英雄」字段、攻击力大于0且可以丢弃的怪兽，用于②效果作为丢弃cost。
function c14124483.costfilter(c)
	return c:IsSetCard(0x8) and c:GetAttack()>0 and c:IsDiscardable()
end
-- ②效果的cost处理：chk==0时检查手牌是否存在可丢弃的「英雄」怪兽；执行时选择1只满足条件的「英雄」怪兽丢弃去墓地，并将丢弃的怪兽记录到LabelObject。
function c14124483.atkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1只可作为②效果cost丢弃的「英雄」怪兽（costfilter）。
	if chk==0 then return Duel.IsExistingMatchingCard(c14124483.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家显示选择要丢弃的手牌的提示信息（HINTMSG_DISCARD）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌中选择1只满足costfilter的「英雄」怪兽作为②效果的cost。
	local g=Duel.SelectMatchingCard(tp,c14124483.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	-- 将选择的「英雄」怪兽以「代价+丢弃」的原因送去墓地，完成②效果的cost。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- ②效果处理：从LabelObject取得被丢弃的怪兽，若自身仍与效果关联且表侧表示，则赋予自身攻击力上升该怪兽攻击力数值的持续效果，持续到回合结束。
function c14124483.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local atk=tc:GetAttack()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到回合结束时上升丢弃的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
