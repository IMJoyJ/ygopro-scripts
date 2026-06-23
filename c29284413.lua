--ジョーカーズ・ナイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把「王后骑士」「卫兵骑士」「国王骑士」之内1只送去墓地才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡直到结束阶段当作和送去墓地的怪兽同名卡使用。
-- ②：自己·对方的结束阶段，以这张卡以外的自己墓地1只战士族·光属性怪兽为对象才能发动。那只怪兽回到卡组，墓地的这张卡加入手卡。
function c29284413.initial_effect(c)
	-- 注册该卡牌可视为「王后骑士」「卫兵骑士」「国王骑士」中任意一张卡的代码
	aux.AddCodeList(c,25652259,64788463,90876561)
	-- ①：从卡组把「王后骑士」「卫兵骑士」「国王骑士」之内1只送去墓地才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡直到结束阶段当作和送去墓地的怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29284413,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,29284413)
	e1:SetCost(c29284413.spcost)
	e1:SetTarget(c29284413.sptg)
	e1:SetOperation(c29284413.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，以这张卡以外的自己墓地1只战士族·光属性怪兽为对象才能发动。那只怪兽回到卡组，墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29284413,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,29284414)
	e2:SetTarget(c29284413.thtg)
	e2:SetOperation(c29284413.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断卡组中是否存在「王后骑士」「卫兵骑士」「国王骑士」中任意一张可作为cost送去墓地的卡
function c29284413.cfilter(c)
	return c:IsCode(25652259,64788463,90876561) and c:IsAbleToGraveAsCost()
end
-- 效果处理函数，检查是否满足cost条件并选择一张卡送去墓地，同时将该卡的卡号记录在效果标签中
function c29284413.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足cost条件，即卡组中是否存在「王后骑士」「卫兵骑士」「国王骑士」中任意一张可作为cost的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c29284413.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡并返回卡组中符合条件的卡组
	local g=Duel.SelectMatchingCard(tp,c29284413.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetCode())
	-- 将选中的卡送去墓地作为cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理函数，检查是否满足特殊召唤条件
function c29284413.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行特殊召唤并设置效果使其在结束阶段变为同名卡
function c29284413.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试特殊召唤这张卡
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local code=e:GetLabel()
		-- 创建一个效果，使该卡在结束阶段变为与送去墓地的怪兽同名卡
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 过滤函数，用于判断墓地中是否存在战士族·光属性且可返回卡组的怪兽
function c29284413.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeck()
end
-- 效果处理函数，设置选择目标并设置操作信息
function c29284413.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c29284413.tdfilter(chkc) and chkc~=c end
	-- 检查是否满足发动条件，即墓地中是否存在符合条件的怪兽和该卡能返回手牌
	if chk==0 then return Duel.IsExistingTarget(c29284413.tdfilter,tp,LOCATION_GRAVE,0,1,c) and c:IsAbleToHand() end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的卡并返回墓地中的卡组
	local g=Duel.SelectTarget(tp,c29284413.tdfilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 设置操作信息，表示将要将目标怪兽返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息，表示将要将该卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果处理函数，执行将目标怪兽返回卡组并使该卡返回手牌
function c29284413.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效并成功返回卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		and c:IsRelateToEffect(e) then
		-- 将该卡返回手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
