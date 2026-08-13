--機関重連アンガー・ナックル
-- 效果：
-- 机械族怪兽2只
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。这张卡不能作为连接素材。
-- ①：自己·对方的主要阶段，把自己的手卡·场上1只怪兽送去墓地，以自己墓地1只机械族·10星怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：这张卡在墓地存在的场合，把自己的手卡·场上1张卡送去墓地才能发动。这张卡特殊召唤。
function c146746.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：使用且仅使用2只机械族怪兽作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：自己·对方的主要阶段，把自己的手卡·场上1只怪兽送去墓地，以自己墓地1只机械族·10星怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(146746,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,146746)
	e1:SetCondition(c146746.spcon1)
	e1:SetCost(c146746.spcost1)
	e1:SetTarget(c146746.sptg1)
	e1:SetOperation(c146746.spop1)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡在墓地存在的场合，把自己的手卡·场上1张卡送去墓地才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,146746)
	e2:SetCost(c146746.spcost2)
	e2:SetTarget(c146746.sptg2)
	e2:SetOperation(c146746.spop2)
	c:RegisterEffect(e2)
	-- 这张卡不能作为连接素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：当前阶段必须为主要阶段1或主要阶段2，即只能在自己·对方的主要阶段发动。
function c146746.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否处于主要阶段1或主要阶段2，满足其一则通过条件。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 费用筛选函数：选择1只怪兽作为发动代价，要求它能作为代价送去墓地，且从场上离开后自己仍有可用的怪兽区。
function c146746.cfilter1(c,tp)
	-- 判断该卡是怪兽、能作为代价送墓，并且送墓或离场后我方仍有空余的怪兽区。
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的代价处理：先检查是否存在满足条件的怪兽；存在则提示玩家从手卡·场上选择1只怪兽，将其送去墓地作为发动代价。
function c146746.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手卡·场上存在至少1只可作为代价送墓且满足后续空位要求的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c146746.cfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	-- 发送选择提示消息，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己手卡·场上选择1只满足cfilter1条件的怪兽，作为①效果的发动代价。
	local g=Duel.SelectMatchingCard(tp,c146746.cfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	-- 将选中的怪兽送去墓地，作为效果的发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 对象筛选函数：选择自己墓地1只机械族·10星怪兽，且该怪兽能够以表侧守备表示被特殊召唤。
function c146746.spfilter1(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的目标处理：检查并选择自己墓地1只机械族·10星且可特殊召唤的怪兽作为对象，同时登记特殊召唤的操作信息。
function c146746.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c146746.spfilter1(chkc,e,tp) end
	-- 发动时点检查：确认自己墓地存在至少1只满足条件的机械族·10星怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c146746.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 发送选择提示消息，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足spfilter1条件的机械族·10星怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c146746.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次连锁将进行1只怪兽的特殊召唤操作，供相关卡牌进行时点或效果对应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将对象怪兽以表侧守备表示特殊召唤；若特殊召唤成功，则为该怪兽附加效果无效化状态，最后完成特殊召唤处理。
function c146746.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这个效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联，并尝试将其以表侧守备表示特殊召唤，成功则继续附加无效化效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 结束特殊召唤的批量处理，统一结算特殊召唤成功后的时点。
	Duel.SpecialSummonComplete()
end
-- ②效果的费用筛选函数：选择1张能被作为代价送去墓地的卡，且该卡离场后自己仍有可用的怪兽区（供这张卡自身特殊召唤）。
function c146746.cfilter2(c,tp)
	-- 判断该卡能作为代价送墓，且送墓或离场后我方仍有空余的怪兽区。
	return c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- ②效果的代价处理：先检查是否存在满足条件的卡；存在则提示玩家从手卡·场上选择1张卡送去墓地作为发动代价。
function c146746.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手卡·场上存在至少1张可作为代价送墓且满足后续空位要求的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c146746.cfilter2,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	-- 发送选择提示消息，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己手卡·场上选择1张满足cfilter2条件的卡，作为②效果的发动代价。
	local g=Duel.SelectMatchingCard(tp,c146746.cfilter2,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选中的卡送去墓地，作为效果的发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的目标处理：确认这张卡在墓地且可以被特殊召唤，然后登记对这张卡自身的特殊召唤操作信息。
function c146746.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁将特殊召唤这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍在墓地且与效果关联，则将其以表侧攻击表示特殊召唤。
function c146746.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
