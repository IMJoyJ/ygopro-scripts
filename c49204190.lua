--奇策
-- 效果：
-- ①：从手卡丢弃1只怪兽，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降因为这个效果发动而丢弃的怪兽的攻击力数值。
function c49204190.initial_effect(c)
	-- 创建效果对象，设置为魔法卡发动效果，具有改变攻击力的分类，可以于伤害步骤发动，无特殊条件限制
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 效果发动时机限制：只能在伤害步骤前发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c49204190.cost)
	e1:SetTarget(c49204190.target)
	e1:SetOperation(c49204190.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择手牌中攻击力大于0且可丢弃的怪兽
function c49204190.cfilter(c)
	return c:GetAttack()>0 and c:IsDiscardable()
end
-- 效果发动的费用处理：检索满足条件的手卡怪兽并将其丢弃至墓地
function c49204190.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足费用条件：确认场上是否存在满足条件的手卡怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c49204190.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要丢弃的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的手卡怪兽作为丢弃对象
	local g=Duel.SelectMatchingCard(tp,c49204190.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetAttack())
	-- 将选中的手卡怪兽送入墓地作为发动费用
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 设置效果的目标选择函数：选择场上表侧表示的怪兽作为目标
function c49204190.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否满足目标选择条件：确认场上是否存在至少一只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果发动时的处理函数：为选定的目标怪兽增加攻击力下降效果
function c49204190.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 为选定目标怪兽添加攻击力下降的效果，数值等于丢弃怪兽的攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
