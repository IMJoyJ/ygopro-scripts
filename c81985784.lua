--デスグレムリン
-- 效果：
-- ①：这张卡反转的场合，以自己墓地1张卡为对象发动。那张卡回到卡组。
function c81985784.initial_effect(c)
	-- ①：这张卡反转的场合，以自己墓地1张卡为对象发动。那张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81985784,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c81985784.target)
	e1:SetOperation(c81985784.operation)
	c:RegisterEffect(e1)
end
-- 过滤可以回到卡组的卡片
function c81985784.filter(c)
	return c:IsAbleToDeck()
end
-- 效果①的发动准备（检查对象合法性、提示玩家并选择对象、设置操作信息）
function c81985784.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c81985784.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1张可以回到卡组的卡作为效果对象
	local g=Duel.SelectTarget(tp,c81985784.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果①的效果处理（将作为对象的卡片送回卡组并洗牌）
function c81985784.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
