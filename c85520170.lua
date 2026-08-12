--くず鉄の神像
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己的墓地·除外状态的1只7·8星的龙族同调怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到额外卡组。发动后这张卡不送去墓地，直接盖放。
-- ②：盖放的这张卡被对方的效果破坏的场合才能发动。从额外卡组把1只「红龙」特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（特殊召唤墓地·除外的7·8星龙族同调怪兽并盖回）和②效果（盖放的这张卡被对方效果破坏时从额外卡组特召「红龙」）。
function s.initial_effect(c)
	-- 将「红龙」加入此卡的关联卡片密码列表中。
	aux.AddCodeList(c,63436931)
	-- ①：以自己的墓地·除外状态的1只7·8星的龙族同调怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到额外卡组。发动后这张卡不送去墓地，直接盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被对方的效果破坏的场合才能发动。从额外卡组把1只「红龙」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检索自己墓地或除外状态的、等级为7或8星的龙族同调怪兽，且该怪兽可以被特殊召唤。
function s.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(7,8)
		and c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备，判断是否满足发动条件，并选择1只符合条件的怪兽作为效果对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.filter(chkc,e,tp) end
	-- 检查发动条件：当前玩家场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查发动条件：自己的墓地或除外状态是否存在至少1只满足过滤条件的怪兽。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择1只墓地或除外状态的、满足过滤条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息，表示该效果包含特殊召唤选定对象的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的执行函数，处理特殊召唤、结束阶段回到额外卡组的延迟效果，以及将此卡自身重新盖放。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的第一个效果对象（即要特殊召唤的怪兽）。
	local tc=Duel.GetFirstTarget()
	local fid=e:GetHandler():GetFieldID()
	-- 检查对象怪兽是否仍与效果相关，且不受「王家之谷」等卡片效果的影响。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示特殊召唤到发动效果的玩家场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段回到额外卡组。发动后这张卡不送去墓地，直接盖放。②：盖放的这张卡被对方的效果破坏的场合才能发动。从额外卡组把1只「红龙」特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.tdcon)
		e1:SetOperation(s.tdop)
		-- 注册在结束阶段将特殊召唤的怪兽送回额外卡组的延迟效果。
		Duel.RegisterEffect(e1,tp)
	end
	if c:IsRelateToEffect(e) and c:IsCanTurnSet() then
		-- 中断当前效果处理，使后续的盖放操作与特殊召唤不视为同时处理。
		Duel.BreakEffect()
		c:CancelToGrave()
		-- 将这张卡在场上里侧表示盖放。
		Duel.ChangePosition(c,POS_FACEDOWN)
		-- 触发“卡片被效果盖放”的时点事件。
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
-- 延迟效果的条件判断函数：检查对象怪兽是否仍带有标记，若标记不符则重置该效果。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 延迟效果的执行函数：将特殊召唤的怪兽送回额外卡组。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽因效果送回持有者的额外卡组。
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- ②效果的发动条件：此卡在己方场上里侧盖放状态下，因对方的效果被破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
-- 过滤函数：检索额外卡组中的「红龙」，且该怪兽可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsCode(63436931) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查发动条件：从额外卡组特殊召唤怪兽时，己方场上是否有可用的额外怪兽区域或主怪兽区域空格。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的发动准备，判断额外卡组是否存在可特召的「红龙」并设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件：己方额外卡组是否存在至少1只满足过滤条件的「红龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示该效果包含从额外卡组特殊召唤怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的执行函数，从额外卡组特殊召唤1只「红龙」。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方额外卡组中第1只满足过滤条件的「红龙」。
	local tg=Duel.GetFirstMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if tg then
		-- 将选定的「红龙」以表侧表示特殊召唤。
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
