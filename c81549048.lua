--竜華三界流転
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·卡组·墓地把1只「龙华」怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
-- ②：把墓地的这张卡除外，以自己的场上·墓地·除外状态的1张「龙华」永续魔法卡为对象才能发动。那张卡回到卡组最下面。那之后，自己抽1张。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（特殊召唤）和②效果（墓地除外回收抽卡）。
function s.initial_effect(c)
	-- ①：从自己的手卡·卡组·墓地把1只「龙华」怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己的场上·墓地·除外状态的1张「龙华」永续魔法卡为对象才能发动。那张卡回到卡组最下面。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置发动效果的Cost为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡·卡组·墓地中可以特殊召唤的「龙华」怪兽。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1c0)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与合法性检测（检查怪兽区域空位及是否存在可特召的「龙华」怪兽）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡、卡组、墓地是否存在至少1只满足特召条件的「龙华」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为：从手卡、卡组、墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的处理：特殊召唤1只「龙华」怪兽，并注册在结束阶段使其回到手卡的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡、卡组、墓地选择1只满足条件的「龙华」怪兽（受王家之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 若成功选择并以表侧表示特殊召唤该怪兽。
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=g:GetFirst()
		if not tc:IsLocation(LOCATION_MZONE) then return end
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段回到手卡。②：把墓地的这张卡除外，以自己的场上·墓地·除外状态的1张「龙华」永续魔法卡为对象才能发动。那张卡回到卡组最下面。那之后，自己抽1张。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.thcon)
		e1:SetOperation(s.thop)
		-- 注册在结束阶段将该怪兽送回手卡的全局延迟效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段回到手卡效果的发动条件：检查目标怪兽是否仍带有对应的标记，若无则重置此效果。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else
		return true
	end
end
-- 结束阶段回到手卡效果的处理：将目标怪兽送回手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将特殊召唤的怪兽送回持有者的手卡。
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
-- 过滤条件：场上、墓地、除外状态的「龙华」永续魔法卡，且能回到卡组。
function s.cfilter(c)
	return bit.band(c:GetType(),TYPE_SPELL+TYPE_CONTINUOUS)==TYPE_SPELL+TYPE_CONTINUOUS
		and c:IsFaceupEx() and c:IsSetCard(0x1c0) and c:IsAbleToDeck()
end
-- ②效果的发动准备与合法性检测（选择目标卡片并确认玩家可以抽卡）。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_ONFIELD) and chkc:IsControler(tp) and s.cfilter(chkc) end
	-- 检查自己的场上、墓地、除外状态是否存在至少1张满足条件的「龙华」永续魔法卡。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		-- 检查自己当前是否可以抽卡。
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择1张场上、墓地或除外状态的「龙华」永续魔法卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置连锁处理的操作信息为：将选中的卡片送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置连锁处理的操作信息为：自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理：将作为对象的卡送回卡组最下面，然后自己抽1张卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的目标卡片。
	local g=Duel.GetTargetsRelateToChain()
	if g:IsExists(Card.IsHasEffect,1,nil,EFFECT_NECRO_VALLEY) then return end
	-- 将目标卡片送回持有者卡组的最下面，并检查是否成功。
	if Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)<1
		or not g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
	-- 中断当前效果处理，使后续的抽卡处理不与回卡组同时进行（造成错时点）。
	Duel.BreakEffect()
	-- 让自己从卡组抽1张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
end
