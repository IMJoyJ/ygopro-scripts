--電光千鳥
-- 效果：
-- 风属性4星怪兽×2
-- 这张卡超量召唤成功时，选择对方场上盖放的1张卡回到持有者卡组最下面。此外，1回合1次，把这张卡1个超量素材取除才能发动。选择对方场上表侧表示存在的1张卡回到持有者卡组最上面。
function c22653490.initial_effect(c)
	-- 添加超量召唤手续，要求使用风属性怪兽作为素材，等级为4，最少需要2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND),4,2)
	c:EnableReviveLimit()
	-- 这张卡超量召唤成功时，选择对方场上盖放的1张卡回到持有者卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22653490,0))  --"返回卡组最下面"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c22653490.tdcon1)
	e1:SetTarget(c22653490.tdtg1)
	e1:SetOperation(c22653490.tdop1)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，把这张卡1个超量素材取除才能发动。选择对方场上表侧表示存在的1张卡回到持有者卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22653490,1))  --"返回卡组最上面"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c22653490.tdcost2)
	e2:SetTarget(c22653490.tdtg2)
	e2:SetOperation(c22653490.tdop2)
	c:RegisterEffect(e2)
end
-- 效果适用的条件：此卡为超量召唤成功
function c22653490.tdcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤函数：选择的卡必须为盖放状态且能送入卡组
function c22653490.tdfilter1(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
-- 设置效果目标：选择对方场上盖放的一张卡作为目标
function c22653490.tdtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c22653490.tdfilter1(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上盖放的一张卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：确定将目标卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理：将目标卡送回对方卡组底端
function c22653490.tdop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsFacedown() then
		-- 将目标卡送回卡组底端
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
-- 支付效果代价：从自身取除1个超量素材
function c22653490.tdcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：选择的卡必须为表侧表示且能送入卡组
function c22653490.tdfilter2(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
-- 设置效果目标：选择对方场上表侧表示的一张卡作为目标
function c22653490.tdtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c22653490.tdfilter2(chkc) end
	-- 检查是否存在符合条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c22653490.tdfilter2,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上表侧表示的一张卡作为目标
	local g=Duel.SelectTarget(tp,c22653490.tdfilter2,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：确定将目标卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：将目标卡送回对方卡组顶端
function c22653490.tdop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsFaceup() then
		-- 将目标卡送回卡组顶端
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
