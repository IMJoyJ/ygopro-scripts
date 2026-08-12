--『守備』封じ
-- 效果：
-- ①：以对方场上1只守备表示怪兽为对象才能发动。那只对方怪兽变成表侧攻击表示。
function c63102017.initial_effect(c)
	-- ①：以对方场上1只守备表示怪兽为对象才能发动。那只对方怪兽变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c63102017.target)
	e1:SetOperation(c63102017.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与检测函数，用于确认是否存在合法对象并进行选择
function c63102017.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsDefensePos() end
	-- 在发动阶段的检测：检查对方场上是否存在至少1只可以作为对象的守备表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上1只守备表示怪兽作为该效果的对象
	local g=Duel.SelectTarget(tp,Card.IsDefensePos,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表明此效果包含改变表示形式的操作，涉及卡片为选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理函数，将选中的对象怪兽改变为表侧攻击表示
function c63102017.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的第一个（也是唯一一个）对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsAttackPos() then
		-- 将目标怪兽的表示形式变更为表侧攻击表示
		Duel.ChangePosition(tc,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
