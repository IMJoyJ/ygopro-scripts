--PSYフレーム・オーバーロード
-- 效果：
-- ①：1回合1次，从自己手卡以及自己场上的表侧表示怪兽之中把1只「PSY骨架」怪兽除外，以场上1张卡为对象才能把这个效果发动。那张卡里侧表示除外。
-- ②：把墓地的这张卡除外才能发动。从卡组把「PSY骨架超载」以外的1张「PSY骨架」卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c36970611.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ①：1回合1次，从自己手卡以及自己场上的表侧表示怪兽之中把1只「PSY骨架」怪兽除外，以场上1张卡为对象才能把这个效果发动。那张卡里侧表示除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36970611,0))  --"除外"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCost(c36970611.cost)
	e2:SetTarget(c36970611.target)
	e2:SetOperation(c36970611.operation)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外才能发动。从卡组把「PSY骨架超载」以外的1张「PSY骨架」卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36970611,1))  --"加入手牌"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_FREE_CHAIN)
	-- 效果发动时，若此卡在墓地则不能发动，用于设置效果发动的限制条件
	e3:SetCondition(aux.exccon)
	-- 效果发动时，需要将此卡从墓地除外作为费用，用于设置效果发动的费用条件
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c36970611.thtg)
	e3:SetOperation(c36970611.thop)
	c:RegisterEffect(e3)
end
-- 用于过滤场上可以被除外的卡，要求是能被除外且不等于xc的卡
function c36970611.tgfilter(c,tp,xc)
	return c:IsAbleToRemove(tp,POS_FACEDOWN) and c~=xc
end
-- 用于过滤手牌或场上的「PSY骨架」怪兽，要求是能作为除外费用的怪兽，并且场上存在满足条件的除外对象
function c36970611.cfilter(c,tp,xc)
	return c:IsSetCard(0xc1) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToRemoveAsCost()
		-- 检查场上是否存在满足tgfilter条件的卡，用于确认是否能发动效果
		and Duel.IsExistingTarget(c36970611.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,tp,xc)
end
-- 效果发动时，选择满足条件的「PSY骨架」怪兽作为除外费用，将该怪兽除外
function c36970611.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local xc=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then xc=e:GetHandler() end
	-- 判断是否满足发动条件，即是否存在满足cfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c36970611.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp,xc) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足cfilter条件的卡作为除外费用
	local cg=Duel.SelectMatchingCard(tp,c36970611.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp,xc)
	-- 将选中的卡以正面表示形式除外作为发动效果的费用
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
end
-- 设置效果的目标，选择场上一张卡作为除外对象
function c36970611.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove(tp,POS_FACEDOWN) end
	if chk==0 then return true end
	local xg=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then xg=e:GetHandler() end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上一张卡作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,xg,tp,POS_FACEDOWN)
	-- 设置效果处理信息，表示将要除外一张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理时，将目标卡以里侧表示形式除外
function c36970611.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以里侧表示形式除外
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end
-- 用于过滤卡组中满足条件的「PSY骨架」卡，排除自己本身
function c36970611.thfilter(c)
	return c:IsSetCard(0xc1) and not c:IsCode(36970611) and c:IsAbleToHand()
end
-- 设置效果的目标，检查卡组中是否存在满足条件的卡
function c36970611.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即卡组中是否存在满足thfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c36970611.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示将要将一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时，从卡组中选择一张满足条件的卡加入手牌
function c36970611.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足thfilter条件的卡作为加入手牌的对象
	local g=Duel.SelectMatchingCard(tp,c36970611.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
