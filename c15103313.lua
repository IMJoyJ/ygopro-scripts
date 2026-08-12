--即神仏
-- 效果：
-- 选择自己场上存在的1只怪兽送去墓地。
function c15103313.initial_effect(c)
	-- 选择自己场上存在的1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c15103313.target)
	e1:SetOperation(c15103313.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组
function c15103313.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择1只自己场上的怪兽作为目标
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息为送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 将目标怪兽送去墓地
function c15103313.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) then
		-- 将目标怪兽以效果为原因送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
