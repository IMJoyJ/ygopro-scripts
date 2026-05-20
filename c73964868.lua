--セイクリッド・プレアデス
-- 效果：
-- 光属性5星怪兽×2
-- ①：自己·对方回合1次，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡回到手卡。
function c73964868.initial_effect(c)
	-- 添加XYZ召唤手续：需要2只5星的光属性怪兽。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),5,2)
	c:EnableReviveLimit()
	-- ①：自己·对方回合1次，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73964868,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c73964868.thcost)
	e1:SetTarget(c73964868.thtg)
	e1:SetOperation(c73964868.thop)
	c:RegisterEffect(e1)
end
-- 效果发动的代价：取除这张卡的1个超量素材。
function c73964868.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动的目标选择：以场上1张卡为对象。
function c73964868.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 检查场上是否存在可以回到手牌的卡作为合法的效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择场上1张可以回到手牌的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，表示该效果会将选中的1张卡送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：使作为对象的卡回到手牌。
function c73964868.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
