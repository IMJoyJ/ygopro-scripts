--燐廻の三弦猫
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
-- ②：这张卡在墓地存在的场合，以自己墓地1只其他的同调怪兽为对象才能发动。那只怪兽回到额外卡组，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 定义卡片的初始效果函数：注册同调召唤手续、①的对方主要阶段同调召唤效果（e1）和②的墓地起效特殊召唤效果（e2）。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整1只（任意）+ 调整以外的怪兽1只以上，组成同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.sccon)
	e1:SetTarget(s.sctarg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己墓地1只其他的同调怪兽为对象才能发动。那只怪兽回到额外卡组，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：仅在对方回合的主要阶段1或主要阶段2时允许发动。
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前是对方的回合（回合玩家不是这张卡的控制者）。
	return Duel.GetTurnPlayer()~=tp
		-- 当前阶段为主要阶段1或主要阶段2。
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- ①效果的发动处理：确认存在可用这张卡进行同调召唤的额外怪兽，并设定特殊召唤的操作信息。
function s.sctarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动合法性检查：额外卡组存在1只以这张卡为素材可以同调召唤的同调怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c) end
	-- 设置操作信息：本次处理包含从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的处理：确认这张卡仍在己方场上且效果有效，选择额外卡组中可同调召唤的怪兽，并以这张卡为素材进行同调召唤。
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 取得额外卡组中所有能以这张卡为素材进行同调召唤的同调怪兽。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 弹出“选择要特殊召唤的卡”的提示，等待玩家选择。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡作为同调素材（调整），执行同调召唤，将选择的怪兽特殊召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
-- ②效果的目标过滤器：选择墓地的同调怪兽，且该怪兽可以返回额外卡组。
function s.toefilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- ②效果的发动目标与合法性检查：验证选择对象合法，并检查自己场上可特召区域、这张卡可特殊召唤、墓地存在其他符合条件的同调怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.toefilter(chkc) end
	-- 发动时检查自己场上是否有可用的主要怪兽区域来进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 发动时检查墓地是否存在1只除这张卡以外的、满足条件的同调怪兽可以作为对象。
		and Duel.IsExistingTarget(s.toefilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 弹出“选择要返回卡组的卡”的提示，等待玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1只符合条件的同调怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.toefilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 设置操作信息：所选对象将被返回额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	-- 设置操作信息：这张卡将进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的处理：将对象怪兽返回额外卡组；若返回成功且这张卡仍可特殊召唤，则将其特殊召唤，并附加离场时除外的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将对象怪兽返回持有者卡组并洗牌；若实际返回成功（返回值非0），继续进行后续处理。
	if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_EXTRA)
		-- 特殊召唤前确认自己场上仍有可用的主要怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上；若特殊召唤成功，则继续附加离场除外效果。
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1,true)
		end
	end
end
