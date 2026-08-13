--ジャック・ア・ボーラン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1只不死族怪兽才能发动。这张卡从手卡特殊召唤。
-- ②：对方主要阶段，以自己或者对方的墓地1只不死族怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。那之后，表侧表示的这张卡直到结束阶段除外。这个效果特殊召唤的怪兽从场上离开的场合除外。
local s,id,o=GetID()
-- 注册该卡的两个效果：①为从手卡丢弃1只不死族怪兽后自身特殊召唤的起动效果；②为在对方主要阶段以墓地不死族怪兽为对象特殊召唤、随后自身暂时除外且召唤的怪兽离场时除外的诱发即时效果。
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
-- 定义①效果的cost用过滤函数：筛选手卡中不死族且可以丢弃的怪兽。
function c36016907.spfilter1(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsDiscardable()
end
-- ①效果的cost处理：确认手卡存在可丢弃的不死族怪兽，让玩家选择1张并丢弃到墓地。
function c36016907.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在cost检测阶段检查手卡中是否存在满足条件（不死族且可丢弃）的卡（不包含发动效果的这张卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(c36016907.spfilter1,tp,LOCATION_HAND,0,1,c) end
	-- 向玩家显示“请选择要丢弃的手牌”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手卡选择1张不死族且可丢弃的怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c36016907.spfilter1,tp,LOCATION_HAND,0,1,1,c)
	-- 将选择的怪兽卡作为cost丢弃到墓地。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- ①效果的发动目标检查：确认自己场上有可用的怪兽区域，且这张卡本身能够被特殊召唤。
function c36016907.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本效果将特殊召唤这张卡（对象为c，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：若这张卡仍与效果关联，则将其特殊召唤。
function c36016907.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果选择墓地对象的过滤函数：筛选墓地中不死族且能被当前效果特殊召唤的怪兽。
function c36016907.spfilter2(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件判定：必须是对方回合的主要阶段。
function c36016907.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是自己且当前阶段为主要阶段1或主要阶段2（即对方主要阶段）。
	return Duel.GetTurnPlayer()==1-tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- ②效果的目标选择及合法性检查：确认场上空位、选择墓地中满足条件的不死族怪兽为对象，且自身可被除外。
function c36016907.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c36016907.spfilter2(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在可作为效果对象的不死族怪兽，并确认这张卡自身能够被除外。
		and Duel.IsExistingTarget(c36016907.spfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) and c:IsAbleToRemove() end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从双方墓地选择1只不死族怪兽作为效果对象，并将该对象登记为当前连锁的目标。
	local g=Duel.SelectTarget(tp,c36016907.spfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息，声明本效果将特殊召唤目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息，声明本效果将除外这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
-- ②效果的处理：特殊召唤对象怪兽，给它附加不可无效的离场时除外效果；若自身仍表侧且在场上，则将自身暂时除外并在结束阶段返回。
function c36016907.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果发动时选择的目标怪兽（墓地中的不死族怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽仍与本效果关联，并尝试将其表侧表示特殊召唤到自己场上；若召唤成功则继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽从场上离开的场合除外。那之后，表侧表示的这张卡直到结束阶段除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
		if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsAbleToRemove() then
			-- 中断当前效果处理，使后续的除外处理与之前的特殊召唤处理不在同一时点，避免错过时点。
			Duel.BreakEffect()
			-- 将这张卡以表侧表示暂时除外（REASON_TEMPORARY），若除外成功且该卡仍为这张卡本身，则准备在结束阶段将其返回。
			if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
				-- 那之后，表侧表示的这张卡直到结束阶段除外。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_PHASE+PHASE_END)
				e2:SetReset(RESET_PHASE+PHASE_END)
				e2:SetLabelObject(tc)
				e2:SetCountLimit(1)
				e2:SetOperation(c36016907.retop)
				-- 将结束阶段时使暂时除外的这张卡返回场上的效果注册为全局效果。
				Duel.RegisterEffect(e2,tp)
			end
		end
	end
end
-- ②效果中结束阶段的处理函数：将暂时除外的这张卡返回场上。
function c36016907.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的这张卡返回场上。
	Duel.ReturnToField(e:GetHandler())
end
