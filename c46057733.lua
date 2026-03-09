--燐廻の三弦猫
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
-- ②：这张卡在墓地存在的场合，以自己墓地1只其他的同调怪兽为对象才能发动。那只怪兽回到额外卡组，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤程序并注册两个效果
function s.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
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
	-- ②：这张卡在墓地存在的场合，以自己墓地1只其他的同调怪兽为对象才能发动。那只怪兽回到额外卡组，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
-- 判断是否为对方主要阶段
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
		-- 判断当前阶段是否为主要阶段1或2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 设置①效果的发动条件和目标
function s.sctarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否存在满足同调召唤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行①效果的处理程序
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取满足同调召唤条件的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 执行同调召唤手续
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
-- 定义过滤函数，用于筛选可送回额外卡组的同调怪兽
function s.toefilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- 设置②效果的发动条件和目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.toefilter(chkc) end
	-- 检查是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(s.toefilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.toefilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 设置连锁操作信息，表示将要送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	-- 设置连锁操作信息，表示将要特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行②效果的处理程序
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将目标怪兽送回额外卡组
	if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_EXTRA)
		-- 检查是否有足够的特殊召唤位置
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 设置效果特殊召唤后从场上离开时的处理，使其被移除
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
