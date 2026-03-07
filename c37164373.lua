--クイーンマドルチェ・ティアラミス
-- 效果：
-- 4星「魔偶甜点」怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己墓地最多2张「魔偶甜点」卡为对象才能发动。那些卡回到卡组，让最多有回去数量的对方场上的卡回到卡组。
function c37164373.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，需要满足种族为魔偶甜点且等级为4的怪兽叠放，最少2只最多2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x71),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己墓地最多2张「魔偶甜点」卡为对象才能发动。那些卡回到卡组，让最多有回去数量的对方场上的卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37164373,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c37164373.cost)
	e1:SetTarget(c37164373.target)
	e1:SetOperation(c37164373.operation)
	c:RegisterEffect(e1)
end
-- 支付效果的代价，从自己场上移除1个超量素材
function c37164373.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于筛选种族为魔偶甜点且可以回到卡组的卡片
function c37164373.filter(c)
	return c:IsSetCard(0x71) and c:IsAbleToDeck()
end
-- 设置效果的目标选择函数，用于选择墓地中的魔偶甜点卡
function c37164373.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c37164373.filter(chkc) end
	-- 检查自己墓地是否存在至少1张魔偶甜点卡
	if chk==0 then return Duel.IsExistingTarget(c37164373.filter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方场上是否存在至少1张可以回到卡组的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标卡片，从自己墓地选择1到2张魔偶甜点卡作为效果对象
	local g=Duel.SelectTarget(tp,c37164373.filter,tp,LOCATION_GRAVE,0,1,2,nil)
	-- 设置效果的处理信息，确定将要返回卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果的处理函数，执行将卡返回卡组和对方场上卡返回卡组的操作
function c37164373.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中已选定的目标卡组，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将选定的卡送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA)
	-- 获取对方场上所有可以返回卡组的卡
	local dg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	if ct>0 and dg:GetCount()>0 then
		-- 向玩家提示选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local rg=dg:Select(tp,1,ct,nil)
		-- 显示所选卡片被选为对象的动画效果
		Duel.HintSelection(rg)
		-- 将对方场上的卡送回卡组并洗牌
		Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
