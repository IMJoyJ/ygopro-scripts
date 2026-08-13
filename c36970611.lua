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
	-- 设置效果②的发动条件：这张卡送去墓地的回合不能发动。
	e3:SetCondition(aux.exccon)
	-- 设置效果②的发动代价：把墓地的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c36970611.thtg)
	e3:SetOperation(c36970611.thop)
	c:RegisterEffect(e3)
end
-- 定义对象过滤函数：判定场上1张卡能否作为效果①的对象，要求该卡可以被里侧除外，且不是需要排除的指定卡（如发动中的本卡）。
function c36970611.tgfilter(c,tp,xc)
	return c:IsAbleToRemove(tp,POS_FACEDOWN) and c~=xc
end
-- 定义代价过滤函数：判定手牌或自己场上表侧表示的1只「PSY骨架」怪兽能否作为代价除外，且场上存在能够成为效果对象的卡。
function c36970611.cfilter(c,tp,xc)
	return c:IsSetCard(0xc1) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToRemoveAsCost()
		-- 追加判定：还必须在场上存在满足tgfilter条件的卡，作为效果①的取对象目标。
		and Duel.IsExistingTarget(c36970611.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,tp,xc)
end
-- 效果①的代价处理：从手牌及自己场上的表侧表示怪兽中选择1只「PSY骨架」怪兽除外，作为发动代价。
function c36970611.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local xc=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then xc=e:GetHandler() end
	-- 代价合法性检查：确认当前存在符合条件的「PSY骨架」怪兽可作为代价，且场上存在可选择的除外对象。
	if chk==0 then return Duel.IsExistingMatchingCard(c36970611.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp,xc) end
	-- 弹出选择提示，让玩家选择要作为代价除外的「PSY骨架」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从手牌和自己场上的表侧表示怪兽中选择1只符合条件的「PSY骨架」怪兽。
	local cg=Duel.SelectMatchingCard(tp,c36970611.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp,xc)
	-- 将选择的怪兽表侧表示除外，作为效果①的发动代价。
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
end
-- 效果①的发动时选择对象：以场上1张卡为对象，并设定将其里侧除外。
function c36970611.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove(tp,POS_FACEDOWN) end
	if chk==0 then return true end
	local xg=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then xg=e:GetHandler() end
	-- 弹出选择提示，让玩家选择要里侧除外的场上卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从场上选择1张可以被除外的卡作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,xg,tp,POS_FACEDOWN)
	-- 设定操作信息：本次连锁将除外1张卡，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①处理时：取得对象卡，若其仍与本次效果关联，则将其里侧表示除外。
function c36970611.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果①选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡里侧表示除外（效果处理）。
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end
-- 定义检索过滤函数：检索对象必须为「PSY骨架」卡、不能是「PSY骨架超载」自身、且可以加入手牌。
function c36970611.thfilter(c)
	return c:IsSetCard(0xc1) and not c:IsCode(36970611) and c:IsAbleToHand()
end
-- 效果②的发动条件与目标：确认卡组存在符合条件的「PSY骨架」卡，并设定检索加入手牌的操作信息。
function c36970611.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中存在满足检索条件的「PSY骨架」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c36970611.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定操作信息：本次连锁将从卡组把1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②处理时：从卡组选择1张符合条件的「PSY骨架」卡加入手牌，并让对方确认。
function c36970611.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要加入手牌的「PSY骨架」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足检索条件的「PSY骨架」卡。
	local g=Duel.SelectMatchingCard(tp,c36970611.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
