--A宝玉獣 コバルト・イーグル
-- 效果：
-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
-- ②：把手卡·场上的这张卡送去墓地才能发动。从卡组把1张「高等暗黑结界」加入手卡。
-- ③：1回合1次，以自己场上1张「高等宝玉兽」卡为对象才能发动。那张卡回到持有者手卡或回到卡组最上面。
-- ④：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c45236142.initial_effect(c)
	-- 将该卡效果文本中记载的「高等暗黑结界」（12644061）加入关联卡号列表，用于后续检索/判定等处理。
	aux.AddCodeList(c,12644061)
	-- 启用全局的不入连锁自我送墓标记，使EFFECT_SELF_TOGRAVE效果能被正确触发与处理。
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SELF_TOGRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCondition(c45236142.tgcon)
	c:RegisterEffect(e1)
	-- ④：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(c45236142.repcon)
	e2:SetOperation(c45236142.repop)
	c:RegisterEffect(e2)
	-- ②：把手卡·场上的这张卡送去墓地才能发动。从卡组把1张「高等暗黑结界」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45236142,0))  --"卡组检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e3:SetCost(c45236142.thcost)
	e3:SetTarget(c45236142.thtg)
	e3:SetOperation(c45236142.thop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，以自己场上1张「高等宝玉兽」卡为对象才能发动。那张卡回到持有者手卡或回到卡组最上面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(45236142,1))  --"回到手卡或卡组"
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetTarget(c45236142.target)
	e4:SetOperation(c45236142.operation)
	c:RegisterEffect(e4)
end
-- 效果①的不入连锁自我送墓的适用条件：当前场地区域不存在「高等暗黑结界」。
function c45236142.tgcon(e)
	-- 判定当前场地不是「高等暗黑结界」时，返回true，满足①效果的自灭条件。
	return not Duel.IsEnvironment(12644061)
end
-- 效果④的触发条件：这张卡表侧表示存在于怪兽区域，并且因破坏的原因将被送去墓地。
function c45236142.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 效果④处理：通过改变卡类型让这张卡不进入墓地，而是作为永续魔法卡继续在魔法与陷阱区域表侧放置。
function c45236142.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ④：…当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 效果②发动代价：把这张卡从手卡或场上送去墓地才能发动；此处检查此卡能否作为代价送去墓地。
function c45236142.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 实际执行代价：将这张卡送去墓地，reason为代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 检索过滤条件：卡名为「高等暗黑结界」且能够加入手牌。
function c45236142.thfilter(c)
	return c:IsCode(12644061) and c:IsAbleToHand()
end
-- 效果②的发动目标判定：己方卡组存在符合条件的「高等暗黑结界」；并设置操作信息为从卡组加入手牌。
function c45236142.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 在发动时检查己方卡组是否至少存在1张「高等暗黑结界」且可以加入手牌。
	if chk==0 then return Duel.IsExistingMatchingCard(c45236142.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：本次处理将把1张「高等暗黑结界」加入持有者手牌（不取对象，从卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的结算处理：从卡组选1张「高等暗黑结界」加入手牌，并让对手确认。
function c45236142.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从己方卡组获得第1张符合条件的「高等暗黑结界」。
	local tg=Duel.GetFirstMatchingCard(c45236142.thfilter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将检索到的「高等暗黑结界」加入其持有者的手牌。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 将检索到的那张卡展示给对手确认。
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 效果③的对象选择条件：自己场上表侧表示的「高等宝玉兽」卡，且该卡能够回到手牌或卡组。
function c45236142.filter(c)
	return c:IsSetCard(0x5034) and (c:IsAbleToHand() or c:IsAbleToDeck()) and c:IsFaceup()
end
-- 效果③的发动目标：选择自己场上1张表侧表示的「高等宝玉兽」卡作为对象，并根据对象能力设置操作分类。
function c45236142.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c45236142.filter(chkc) end
	-- 检查场上是否存在1张满足条件的高等宝玉兽卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c45236142.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 给玩家显示选择对象的提示消息（“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1张符合条件的高等宝玉兽卡，并登记为效果对象。
	local g=Duel.SelectTarget(tp,c45236142.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	if not g:GetFirst():IsAbleToHand() then
		-- 如果对象不能回到手牌，则将本次操作信息设置为回卡组（CATEGORY_TODECK）。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	elseif not g:GetFirst():IsAbleToDeck() then
		-- 如果对象不能回到卡组，则将本次操作信息设置为回手牌（CATEGORY_TOHAND）。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- 效果③的结算处理：取回对象，若对象仍合法且表侧表示，则由玩家选择回手牌或回卡组最上面，并执行对应移动。
function c45236142.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果③选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		if tc:IsAbleToHand() and (not tc:IsAbleToDeck()
			-- 当对象既能回手牌也能回卡组时，让玩家选择；选择“回到手卡”（选项0）时进入回手牌分支。
			or Duel.SelectOption(tp,aux.Stringid(45236142,2),aux.Stringid(45236142,3))==0) then  --"回到手卡/回到卡组"
			-- 将对象卡送回其持有者的手牌。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		else
			-- 将对象卡送回其持有者卡组最上面。
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
