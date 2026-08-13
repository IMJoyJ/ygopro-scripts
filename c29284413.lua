--ジョーカーズ・ナイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把「王后骑士」「卫兵骑士」「国王骑士」之内1只送去墓地才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡直到结束阶段当作和送去墓地的怪兽同名卡使用。
-- ②：自己·对方的结束阶段，以这张卡以外的自己墓地1只战士族·光属性怪兽为对象才能发动。那只怪兽回到卡组，墓地的这张卡加入手卡。
function c29284413.initial_effect(c)
	-- 记录本卡上记载的卡名：王后骑士(25652259)、卫兵骑士(90876561)、国王骑士(64788463)，使相关效果能识别这些卡名。
	aux.AddCodeList(c,25652259,64788463,90876561)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从卡组把「王后骑士」「卫兵骑士」「国王骑士」之内1只送去墓地才能发动。这张卡从手卡特殊召唤。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己·对方的结束阶段，以这张卡以外的自己墓地1只战士族·光属性怪兽为对象才能发动。那只怪兽回到卡组，墓地的这张卡加入手卡。
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
-- 定义过滤函数cfilter：判断卡是否为「王后骑士」「卫兵骑士」「国王骑士」之一，并且可以作为代价送入墓地。
function c29284413.cfilter(c)
	return c:IsCode(25652259,64788463,90876561) and c:IsAbleToGraveAsCost()
end
-- 定义代价函数spcost：确认卡组存在可送墓的骑士后，由玩家选择1张符合条件的骑士卡送入墓地作为发动代价，并将其卡号保存到效果标签中。
function c29284413.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查（chk==0）：确认卡组中存在至少1张满足cfilter条件的骑士卡（即王后骑士/卫兵骑士/国王骑士且可作为COST送墓）。
	if chk==0 then return Duel.IsExistingMatchingCard(c29284413.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 弹出选择提示消息，提示玩家正在选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足cfilter条件的骑士卡。
	local g=Duel.SelectMatchingCard(tp,c29284413.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetCode())
	-- 将选中的骑士卡以REASON_COST（规则代价）送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义发动时的目标检查函数sptg：确认自己主要怪兽区有空位，且这张卡可以以表侧表示特殊召唤，方可发动效果。
function c29284413.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：自己主要怪兽区存在可用的空格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次操作信息记录为特殊召唤本卡（处理时遵守特殊召唤限制）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果处理函数spop：若本卡仍与效果关联，则进行特殊召唤，成功后赋予本卡‘当作送去墓地的怪兽同名卡使用’的临时效果，直到结束阶段。
function c29284413.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以不检查召唤条件/苏生限制、表侧表示的方式执行特殊召唤步骤，若特殊召唤成功则进入改变卡名的处理。
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local code=e:GetLabel()
		-- 这个效果特殊召唤的这张卡直到结束阶段当作和送去墓地的怪兽同名卡使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	-- 结束SpecialSummonStep序列，完成特殊召唤处理。
	Duel.SpecialSummonComplete()
end
-- 定义过滤函数tdfilter：判断卡是否为光属性·战士族怪兽且可以回到卡组（用于②的回卡组对象）。
function c29284413.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeck()
end
-- 定义②的目标选择函数thtg：以自己墓地1只光属性战士族怪兽为对象（不能是本卡），且本卡可以加入手卡；记录目标回卡组、本卡回手的操作信息。
function c29284413.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c29284413.tdfilter(chkc) and chkc~=c end
	-- 目标检查：墓地存在至少1只满足条件的光属性战士族怪兽（除本卡外），且本卡能够加入手卡。
	if chk==0 then return Duel.IsExistingTarget(c29284413.tdfilter,tp,LOCATION_GRAVE,0,1,c) and c:IsAbleToHand() end
	-- 弹出选择提示消息，提示玩家正在选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己墓地1只符合条件的战士族·光属性怪兽作为效果对象，并排除本卡。
	local g=Duel.SelectTarget(tp,c29284413.tdfilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 设置操作信息：将选择的对象怪兽在效果处理时返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：将本卡在效果处理时加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 定义②的效果处理函数thop：若对象怪兽仍与效果关联、成功返回卡组（并处于卡组或额外卡组）且本卡仍与效果关联，则将本卡加入手卡。
function c29284413.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时的对象卡（所选墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否仍与效果关联、送回卡组是否成功且当前确实在卡组/额外卡组，同时本卡仍与效果关联。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		and c:IsRelateToEffect(e) then
		-- 将本卡从墓地加入其持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
