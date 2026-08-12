--鳥銃士カステル
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ②：把这张卡2个超量素材取除，以场上1张其他的表侧表示卡为对象才能发动。那张卡回到卡组。
function c82633039.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽2只
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82633039,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,82633039)
	e1:SetCost(c82633039.setcost)
	e1:SetTarget(c82633039.settg)
	e1:SetOperation(c82633039.setop)
	c:RegisterEffect(e1)
	-- ②：把这张卡2个超量素材取除，以场上1张其他的表侧表示卡为对象才能发动。那张卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82633039,1))  --"回到持有者卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,82633039)
	e2:SetCost(c82633039.tdcost)
	e2:SetTarget(c82633039.tdtg)
	e2:SetOperation(c82633039.tdop)
	c:RegisterEffect(e2)
end
-- 效果①的代价：取除这张卡的1个超量素材
function c82633039.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的过滤条件：场上表侧表示且可以变成里侧表示的怪兽
function c82633039.setfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果①的发动准备：检查可行性并选择对象
function c82633039.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c82633039.setfilter(chkc) end
	-- 检查场上是否存在至少1只满足效果①过滤条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c82633039.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择1只满足条件的怪兽作为效果①的对象
	local g=Duel.SelectTarget(tp,c82633039.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：改变1张卡片的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果①的效果处理：将对象怪兽变成里侧守备表示
function c82633039.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽变成里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 效果②的代价：取除这张卡的2个超量素材
function c82633039.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果②的过滤条件：场上表侧表示且可以回到卡组的卡
function c82633039.tdfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
-- 效果②的发动准备：检查可行性并选择对象
function c82633039.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c82633039.tdfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查场上是否存在至少1张除这张卡以外的、满足效果②过滤条件的表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(c82633039.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1张除这张卡以外的、满足条件的表侧表示卡作为效果②的对象
	local g=Duel.SelectTarget(tp,c82633039.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：将1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②的效果处理：将对象卡片送回卡组并洗牌
function c82633039.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡片送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
