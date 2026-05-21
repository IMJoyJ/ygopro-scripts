--終焉の守護者アドレウス
-- 效果：
-- 5星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1张表侧表示卡为对象才能发动。那张卡破坏。
function c94119480.initial_effect(c)
	-- 添加超量召唤手续：5星怪兽×2
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
-- 代价去处处理：检查并取除这张卡的1个超量素材
function c94119480.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：表侧表示的卡片
function c94119480.filter(c)
	return c:IsFaceup()
end
-- 靶向目标处理：选择对方场上1张表侧表示的卡作为对象，并设置破坏操作信息
function c94119480.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c94119480.filter(chkc) end
	-- 在发动阶段，检查对方场上是否存在至少1张表侧表示的卡可以作为对象
	if chk==0 then return Duel.IsExistingTarget(c94119480.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,c94119480.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，表示该效果会破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果解决处理：若对象卡仍存在且表侧表示，则将其破坏
function c94119480.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
