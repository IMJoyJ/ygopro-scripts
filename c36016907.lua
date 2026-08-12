--ジャック・ア・ボーラン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1只不死族怪兽才能发动。这张卡从手卡特殊召唤。
-- ②：对方主要阶段，以自己或者对方的墓地1只不死族怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。那之后，表侧表示的这张卡直到结束阶段除外。这个效果特殊召唤的怪兽从场上离开的场合除外。
local s,id,o=GetID()
-- 创建并注册两个效果，分别是①从手卡丢弃不死族怪兽特殊召唤自身和②对方主要阶段从墓地特殊召唤不死族怪兽并除外自身。
function c36016907.initial_effect(c)
	-- ①：从手卡丢弃1只不死族怪兽才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36016907,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,36016907)
	e1:SetCost(c36016907.spcost1)
	e1:SetTarget(c36016907.sptg1)
	e1:SetOperation(c36016907.spop1)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段，以自己或者对方的墓地1只不死族怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。那之后，表侧表示的这张卡直到结束阶段除外。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36016907,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,36016908)
	e2:SetCondition(c36016907.spcon2)
	e2:SetTarget(c36016907.sptg2)
	e2:SetOperation(c36016907.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在可丢弃的不死族怪兽。
function c36016907.spfilter1(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsDiscardable()
end
-- 效果处理函数，检查是否满足丢弃条件并选择丢弃的卡牌。
function c36016907.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡中是否存在至少1张不死族怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c36016907.spfilter1,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要丢弃的卡牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择1张手卡中的不死族怪兽作为丢弃对象。
	local g=Duel.SelectMatchingCard(tp,c36016907.spfilter1,tp,LOCATION_HAND,0,1,1,c)
	-- 将选中的卡牌送入墓地作为费用。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果处理函数，判断是否可以特殊召唤自身。
function c36016907.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有足够的空间进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数，执行特殊召唤自身。
function c36016907.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断墓地中是否存在可特殊召唤的不死族怪兽。
function c36016907.spfilter2(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数，判断是否满足发动条件（对方主要阶段）。
function c36016907.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方且当前阶段为对方主要阶段1或主要阶段2。
	return Duel.GetTurnPlayer()==1-tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果处理函数，判断是否可以发动效果并选择目标。
function c36016907.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c36016907.spfilter2(chkc,e,tp) end
	-- 检查场上是否有足够的空间进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在至少1张不死族怪兽卡作为目标。
		and Duel.IsExistingTarget(c36016907.spfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) and c:IsAbleToRemove() end
	-- 提示玩家选择要特殊召唤的卡牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1张墓地中的不死族怪兽作为特殊召唤对象。
	local g=Duel.SelectTarget(tp,c36016907.spfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息，表示将特殊召唤目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息，表示将自身除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
-- 效果处理函数，执行特殊召唤目标怪兽并除外自身。
function c36016907.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 为特殊召唤的怪兽设置效果，使其离开场时被除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
		if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsAbleToRemove() then
			-- 中断当前效果处理，防止时点错乱。
			Duel.BreakEffect()
			-- 判断是否满足除外自身条件（自身为表侧表示且可除外）。
			if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
				-- 注册一个回合结束时将自身返回场上的效果。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_PHASE+PHASE_END)
				e2:SetReset(RESET_PHASE+PHASE_END)
				e2:SetLabelObject(tc)
				e2:SetCountLimit(1)
				e2:SetOperation(c36016907.retop)
				-- 将效果注册到玩家环境中。
				Duel.RegisterEffect(e2,tp)
			end
		end
	end
end
-- 返回场上的处理函数。
function c36016907.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身返回到场上。
	Duel.ReturnToField(e:GetHandler())
end
