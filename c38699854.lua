--太陽の書
-- 效果：
-- ①：以场上1只里侧表示怪兽为对象才能发动。那只里侧表示怪兽变成表侧攻击表示。
function c38699854.initial_effect(c)
	-- ①：以场上1只里侧表示怪兽为对象才能发动。那只里侧表示怪兽变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c38699854.target)
	e1:SetOperation(c38699854.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的里侧表示怪兽
function c38699854.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFacedown() end
	-- 检查是否存里侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择里侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择一只里侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果的处理信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 将选中的里侧表示怪兽变为表侧攻击表示
function c38699854.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 将对象怪兽变为表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end
