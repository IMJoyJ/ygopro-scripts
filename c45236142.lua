--A宝玉獣 コバルト・イーグル
-- 效果：
-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
-- ②：把手卡·场上的这张卡送去墓地才能发动。从卡组把1张「高等暗黑结界」加入手卡。
-- ③：1回合1次，以自己场上1张「高等宝玉兽」卡为对象才能发动。那张卡回到持有者手卡或回到卡组最上面。
-- ④：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c45236142.initial_effect(c)
	-- 记录该卡具有「高等暗黑结界」的卡名信息
	aux.AddCodeList(c,12644061)
	-- 启用全局标记，用于检测是否因自身效果送入墓地
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
-- 判断是否满足①效果的条件：场地区域没有「高等暗黑结界」存在
function c45236142.tgcon(e)
	-- 若场地区域没有「高等暗黑结界」存在，则触发效果
	return not Duel.IsEnvironment(12644061)
end
-- 判断是否满足④效果的条件：此卡在怪兽区域被破坏
function c45236142.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 将此卡变为永续魔法卡类型并放置于魔法与陷阱区域
function c45236142.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将此卡变为永续魔法卡类型并放置于魔法与陷阱区域
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- ②效果的费用支付：将此卡送入墓地
function c45236142.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送入墓地作为②效果的费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 检索过滤函数：寻找卡号为「高等暗黑结界」且可送入手卡的卡
function c45236142.thfilter(c)
	return c:IsCode(12644061) and c:IsAbleToHand()
end
-- ②效果的发动条件判断：确认卡组中是否存在「高等暗黑结界」
function c45236142.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 确认卡组中是否存在「高等暗黑结界」
	if chk==0 then return Duel.IsExistingMatchingCard(c45236142.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置②效果的处理信息：将1张「高等暗黑结界」送入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组检索并送入手卡
function c45236142.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中满足条件的第一张「高等暗黑结界」
	local tg=Duel.GetFirstMatchingCard(c45236142.thfilter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将检索到的「高等暗黑结界」送入手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方确认送入手卡的「高等暗黑结界」
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 目标过滤函数：筛选自己场上的「高等宝玉兽」卡
function c45236142.filter(c)
	return c:IsSetCard(0x5034) and (c:IsAbleToHand() or c:IsAbleToDeck()) and c:IsFaceup()
end
-- ③效果的发动条件判断：确认自己场上是否存在「高等宝玉兽」卡
function c45236142.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c45236142.filter(chkc) end
	-- 确认自己场上是否存在「高等宝玉兽」卡
	if chk==0 then return Duel.IsExistingTarget(c45236142.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上的一张「高等宝玉兽」卡作为效果对象
	local g=Duel.SelectTarget(tp,c45236142.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	if not g:GetFirst():IsAbleToHand() then
		-- 设置③效果的处理信息：将对象卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	elseif not g:GetFirst():IsAbleToDeck() then
		-- 设置③效果的处理信息：将对象卡送回手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- ③效果的处理：将对象卡送回手卡或卡组
function c45236142.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		if tc:IsAbleToHand() and (not tc:IsAbleToDeck()
			-- 若对象卡可送回手卡且对方选择送回手卡，则送回手卡
			or Duel.SelectOption(tp,aux.Stringid(45236142,2),aux.Stringid(45236142,3))==0) then  --"回到手卡/回到卡组"
			-- 将对象卡送回手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		else
			-- 将对象卡送回卡组顶端
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
