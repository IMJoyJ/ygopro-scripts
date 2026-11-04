--終焉の守護者アドレウス
-- 效果：
-- 5星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1张表侧表示卡为对象才能发动。那张卡破坏。
function c94119480.initial_effect(c)
	-- 5星怪兽×2
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1张表侧表示卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetDescription(aux.Stringid(94119480,0))  --"破坏"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c94119480.cost)
	e1:SetTarget(c94119480.target)
	e1:SetOperation(c94119480.operation)
	c:RegisterEffect(e1)
end
-- 取除1个超量素材
function c94119480.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤对方场上表侧表示卡
function c94119480.filter(c)
	return c:IsFaceup()
end
-- 选择对方场上1张表侧表示卡为对象
function c94119480.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c94119480.filter(chkc) end
	-- 检查是否存在可选择的对方场上表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(c94119480.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 以对方场上1张表侧表示卡为对象
	local g=Duel.SelectTarget(tp,c94119480.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏对象卡
function c94119480.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
