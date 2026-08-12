--オルターガイスト・シルキタス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，让自己场上1张其他的「幻变骚灵」卡回到手卡，以对方场上1张卡为对象才能发动。那张卡回到手卡。
-- ②：这张卡从场上送去墓地的场合，以自己墓地1张「幻变骚灵」陷阱卡为对象才能发动。那张卡加入手卡。
function c89538537.initial_effect(c)
	-- ①：自己·对方回合，让自己场上1张其他的「幻变骚灵」卡回到手卡，以对方场上1张卡为对象才能发动。那张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetDescription(aux.Stringid(89538537,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,89538537)
	e1:SetCost(c89538537.rthcost)
	e1:SetTarget(c89538537.rthtg)
	e1:SetOperation(c89538537.rthop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合，以自己墓地1张「幻变骚灵」陷阱卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89538537,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,89538538)
	e2:SetCondition(c89538537.thcon)
	e2:SetTarget(c89538537.thtg)
	e2:SetOperation(c89538537.thop)
	c:RegisterEffect(e2)
end
-- 效果①的Cost函数，由于需要检测可否选择对象，在此处仅设置标记并返回true，实际Cost在Target中处理
function c89538537.rthcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤自己场上表侧表示的「幻变骚灵」卡，且该卡作为Cost回手牌时，对方场上存在可作为对象回手牌的卡
function c89538537.rthcfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x103) and c:IsAbleToHandAsCost()
		-- 检查对方场上是否存在至少1张可以作为对象返回手牌的卡（排除作为Cost回手牌的卡本身，以及装备了该Cost卡的卡）
		and Duel.IsExistingTarget(c89538537.rthtgfilter,tp,0,LOCATION_ONFIELD,1,c,c)
end
-- 过滤对方场上可以返回手牌的卡，且该卡不能是作为Cost回手牌的卡的装备对象
function c89538537.rthtgfilter(c,tc)
	return c:IsAbleToHand() and c:GetEquipTarget()~=tc
end
-- 效果①的Target（发动准备）函数，处理Cost的扣除、选择对方场上的卡作为对象并设置操作信息
function c89538537.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToHand() end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查自己场上是否存在满足Cost条件的「幻变骚灵」卡（排除自身）
			return Duel.IsExistingMatchingCard(c89538537.rthcfilter,tp,LOCATION_ONFIELD,0,1,c,tp)
		else
			-- 检查对方场上是否存在可以作为对象返回手牌的卡
			return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 提示玩家选择要返回手牌的卡（作为Cost）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 玩家选择1张自己场上的「幻变骚灵」卡作为Cost
		local g=Duel.SelectMatchingCard(tp,c89538537.rthcfilter,tp,LOCATION_ONFIELD,0,1,1,c,tp)
		-- 将选择的卡作为Cost送回持有者手牌
		Duel.SendtoHand(g,nil,REASON_COST)
	end
	-- 提示玩家选择要返回手牌的卡（作为效果对象）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张可以返回手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示该效果包含将1张卡送回手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的Operation（效果处理）函数，将作为对象的卡送回手牌
function c89538537.rthop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①锁定的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡必须是从场上送去墓地
function c89538537.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤自己墓地的「幻变骚灵」陷阱卡，且该卡可以加入手牌
function c89538537.thfilter(c)
	return c:IsSetCard(0x103) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的Target（发动准备）函数，选择自己墓地1张「幻变骚灵」陷阱卡作为对象并设置操作信息
function c89538537.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c89538537.thfilter(chkc) end
	-- 检查自己墓地是否存在可以作为对象加入手牌的「幻变骚灵」陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c89538537.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张「幻变骚灵」陷阱卡作为效果对象
	local sg=Duel.SelectTarget(tp,c89538537.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示该效果包含将墓地的卡加入手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果②的Operation（效果处理）函数，将作为对象的墓地陷阱卡加入手牌
function c89538537.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②锁定的对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与效果相关，且不受「王家之谷」的影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将该对象卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
