--超越竜メテオロス
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②③的效果1回合各能使用1次。
-- ①：对方回合才能发动。选这张卡以外的自己的手卡·场上2只恐龙族怪兽破坏，这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1只恐龙族怪兽送去墓地。
-- ③：这张卡被破坏的场合才能发动。从自己墓地选1只通常怪兽回到卡组。那之后，可以把这张卡特殊召唤。
function c31241087.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c31241087.splimit)
	c:RegisterEffect(e0)
	-- ①：对方回合才能发动。选这张卡以外的自己的手卡·场上2只恐龙族怪兽破坏，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31241087,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,31241087)
	e1:SetCondition(c31241087.dspcon)
	e1:SetTarget(c31241087.dsptg)
	e1:SetOperation(c31241087.dspop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1只恐龙族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31241087,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,31241088)
	e2:SetTarget(c31241087.tgtg)
	e2:SetOperation(c31241087.tgop)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合才能发动。从自己墓地选1只通常怪兽回到卡组。那之后，可以把这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31241087,2))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,31241089)
	e3:SetTarget(c31241087.tdtg)
	e3:SetOperation(c31241087.tdop)
	c:RegisterEffect(e3)
end
-- 特殊召唤条件：只允许通过卡的效果（具有EFFECT_TYPE_ACTIONS类型的效果）来特殊召唤，拒绝其他召唤/特殊召唤方式。
function c31241087.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- ①效果的发动条件：对方回合才能发动（即当前回合玩家不是这张卡的控制者）。
function c31241087.dspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是自己，满足①的“对方回合”发动条件。
	return Duel.GetTurnPlayer()~=tp
end
-- 筛选要破坏的卡：恐龙族怪兽，且为手牌中的卡或场上表侧表示的卡，对应‘自己的手卡·场上’的恐龙族怪兽。
function c31241087.desfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsFaceupEx()
end
-- ①效果的发动时点与目标选择：获取手牌中这张卡及场上/手牌的恐龙族候选，检查能否选2只破坏且自身可特殊召唤，并设置破坏与特殊召唤的操作信息。
function c31241087.dsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取己方手牌·场上除这张卡自身以外的所有恐龙族怪兽，作为可破坏的候选集合。
	local g=Duel.GetMatchingGroup(c31241087.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c)
	-- 发动条件判定：能否从候选集合中选出2只恐龙族（且破坏后自己的怪兽区仍有空位），并且这张卡能够特殊召唤。
	if chk==0 then return g:CheckSubGroup(aux.mzctcheck,2,2,tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁将特殊召唤这张卡（1张）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：本次连锁将破坏2只恐龙族怪兽（候选集合为全部可破坏对象）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- ①效果处理：重新获取可破坏的恐龙族怪兽，让玩家选择2只；破坏成功且这张卡仍与效果关联时，将其从手卡特殊召唤。
function c31241087.dspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理阶段重新获取可破坏的恐龙族怪兽集合（手牌·场上除自身外）。
	local g=Duel.GetMatchingGroup(c31241087.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c)
	-- 若没有可选的恐龙族怪兽，或无法选出2只并满足破坏后空位条件，则效果处理终止。
	if #g==0 or not g:CheckSubGroup(aux.mzctcheck,2,2,tp) then return end
	-- 弹出选择提示，要求玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从候选集合中选择2只恐龙族怪兽，同时确保破坏后自己的怪兽区仍有空位可特召这张卡。
	local dg=g:SelectSubGroup(tp,aux.mzctcheck,false,2,2,tp)
	-- 显示被选中的卡为对象，并记录这些卡与当前连锁的关联。
	Duel.HintSelection(dg)
	-- 若破坏处理没有成功，或这张卡已不与该效果关联，则终止后续特殊召唤。
	if Duel.Destroy(dg,REASON_EFFECT)==0 or not c:IsRelateToEffect(e) then return end
	-- 将这张卡从手卡以表侧攻击表示特殊召唤到自己的怪兽区。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 筛选从卡组送去墓地的卡：恐龙族怪兽且可以被送去墓地。
function c31241087.tgfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToGrave()
end
-- ②效果的发动条件与目标设定：卡组中存在符合条件的恐龙族怪兽时，设置从卡组送墓1张的操作信息。
function c31241087.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：卡组中是否存在1只以上恐龙族怪兽可以送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(c31241087.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次连锁将把1张卡从卡组送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只恐龙族怪兽送去墓地。
function c31241087.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只符合条件的恐龙族怪兽。
	local g=Duel.SelectMatchingCard(tp,c31241087.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 筛选从墓地返回卡组的卡：通常怪兽且可以返回卡组。
function c31241087.tdfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
-- ③效果的发动条件与目标设定：墓地存在符合条件的通常怪兽时，设置返回卡组的操作信息，并根据这张卡发动时所在位置调整效果分类（在墓地时追加墓地特殊召唤分类）。
function c31241087.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：墓地中是否存在1只以上通常怪兽可以返回卡组。
	if chk==0 then return Duel.IsExistingMatchingCard(c31241087.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：本次连锁将把1张卡从墓地返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	if e:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	end
end
-- ③效果处理：从墓地选择1只通常怪兽返回卡组；返回成功且这张卡仍与效果关联、自己场上有空格且能特殊召唤时，询问玩家是否将其特殊召唤。
function c31241087.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从墓地选择1只符合条件的通常怪兽。
	local g=Duel.SelectMatchingCard(tp,c31241087.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local c=e:GetHandler()
		-- 将选择的卡返回卡组并洗牌，确认实际返回成功。
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
			and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)>0
			-- 确认这张卡仍与效果关联，且自己场上有可用的怪兽区域。
			and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 询问玩家是否将这张卡特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(31241087,3)) then  --"是否把这张卡特殊召唤？"
			-- 中断当前效果处理，使之后的特殊召唤作为另一次独立处理（错开时点）。
			Duel.BreakEffect()
			-- 将这张卡从墓地以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
