--クイーンマドルチェ・ティアラミス
-- 效果：
-- 4星「魔偶甜点」怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己墓地最多2张「魔偶甜点」卡为对象才能发动。那些卡回到卡组，让最多有回去数量的对方场上的卡回到卡组。
function c37164373.initial_effect(c)
	-- 为这张卡添加超量召唤手续：以2只等级4的「魔偶甜点」怪兽为素材进行超量召唤。
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
-- 发动代价：确认能否移除这张卡的1个超量素材作为代价；实际支付时移除这张卡的1个超量素材。
function c37164373.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 墓地对象的筛选条件：是「魔偶甜点」卡且能够回到卡组。
function c37164373.filter(c)
	return c:IsSetCard(0x71) and c:IsAbleToDeck()
end
-- 发动目标的判定：需要选择自己墓地1~2张满足filter的「魔偶甜点」卡为对象，同时确认对方场上有至少1张可回卡组的卡；若收到对象卡则验证对象卡是否合法。
function c37164373.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c37164373.filter(chkc) end
	-- 判断自己墓地是否存在至少1张满足筛选条件且可以回到卡组的「魔偶甜点」卡作为对象。
	if chk==0 then return Duel.IsExistingTarget(c37164373.filter,tp,LOCATION_GRAVE,0,1,nil)
		-- 判断对方场上是否存在至少1张可以回到卡组的卡，保证效果处理时能够选择弹回卡组的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择卡片的提示信息，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家从自己墓地选择1~2张满足filter的「魔偶甜点」卡，并设定为效果的对象。
	local g=Duel.SelectTarget(tp,c37164373.filter,tp,LOCATION_GRAVE,0,1,2,nil)
	-- 设置操作信息：本效果涉及将对象卡返回卡组，数量为选择的对象数，用于后续发动判定。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理：将对象卡返回卡组并洗牌，然后根据实际返回的数量，在对方场上选择相应数量的卡返回卡组并洗牌。
function c37164373.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得效果对象卡组，并保留仍与效果有联系（未失效/未离场）的对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象卡送回持有者卡组并洗牌，原因是效果处理。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA)
	-- 获取对方场上所有能够返回卡组的卡，作为后续选择的候选集合。
	local dg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	if ct>0 and dg:GetCount()>0 then
		-- 显示选择卡片的提示信息，提示玩家选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local rg=dg:Select(tp,1,ct,nil)
		-- 手动展示所选卡片的选中动画，并标记这些卡为被选择状态。
		Duel.HintSelection(rg)
		-- 将对方场上被选择的卡送回持有者卡组并洗牌，原因是效果处理。
		Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
