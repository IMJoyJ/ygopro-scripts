--ネオフレムベル・レディ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把1只炎属性怪兽送去墓地，以对方墓地1张卡为对象才能发动。那张卡除外。这个效果在对方回合也能发动。
-- ②：这张卡已在怪兽区域存在的状态，从对方墓地有卡被除外的场合才能发动。从卡组把「新炎狱女郎」以外的1只守备力200以下的炎属性怪兽送去墓地。
function c816427.initial_effect(c)
	-- ①：从手卡把1只炎属性怪兽送去墓地，以对方墓地1张卡为对象才能发动。那张卡除外。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(816427,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,816427)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c816427.rmcost)
	e1:SetTarget(c816427.rmtg)
	e1:SetOperation(c816427.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，从对方墓地有卡被除外的场合才能发动。从卡组把「新炎狱女郎」以外的1只守备力200以下的炎属性怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(816427,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,816428)
	e2:SetCondition(c816427.tgcon)
	e2:SetTarget(c816427.tgtg)
	e2:SetOperation(c816427.tgop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可以作为代价送去墓地的炎属性怪兽
function c816427.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGraveAsCost()
end
-- 效果①的代价（Cost）处理函数
function c816427.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以作为代价送去墓地的炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c816427.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡将1只炎属性怪兽送去墓地
	Duel.DiscardHand(tp,c816427.costfilter,1,1,REASON_COST)
end
-- 效果①的对象（Target）处理函数
function c816427.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息为除外对方墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果①的效果处理（Operation）函数
function c816427.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤从对方墓地被除外的卡
function c816427.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(1-tp)
end
-- 效果②的发动条件（Condition）处理函数
function c816427.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c816427.cfilter,1,nil,tp)
end
-- 过滤卡组中「新炎狱女郎」以外的守备力200以下的炎属性怪兽
function c816427.tgfilter(c)
	return c:IsDefenseBelow(200) and c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsCode(816427) and c:IsAbleToGrave()
end
-- 效果②的对象（Target）处理函数
function c816427.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c816427.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为从卡组将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（Operation）函数
function c816427.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c816427.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
