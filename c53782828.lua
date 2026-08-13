--S－Force レトロアクティヴ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把自己场上的怪兽作为「治安战警队」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
-- ②：自己·对方的主要阶段才能发动。这张卡回到持有者手卡，从手卡把1只2星以上的「治安战警队」怪兽特殊召唤。
-- ③：自己场上的「治安战警队」怪兽为让效果发动而把手卡除外的场合，可以作为代替把墓地的这张卡除外。
function c53782828.initial_effect(c)
	-- ①：把自己场上的怪兽作为「治安战警队」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,53782828)
	e1:SetValue(c53782828.matval)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段才能发动。这张卡回到持有者手卡，从手卡把1只2星以上的「治安战警队」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53782828,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,53782829)
	e2:SetCondition(c53782828.spcon)
	e2:SetTarget(c53782828.sptg)
	e2:SetOperation(c53782828.spop)
	c:RegisterEffect(e2)
	-- ③：自己场上的「治安战警队」怪兽为让效果发动而把手卡除外的场合，可以作为代替把墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(55049722)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,53782830)
	c:RegisterEffect(e3)
end
-- 筛选函数：判断卡是否位于我方怪兽区域且由我方控制，用于确认连接素材中是否存在我方场上的怪兽。
function c53782828.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 筛选函数：判断卡是否位于手牌且卡号为此卡，用于检测素材组中是否已包含手牌的这张卡。
function c53782828.exmfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsCode(53782828)
end
-- 连接素材判定函数：连接怪兽必须是「治安战警队」怪兽；在素材组尚未包含手牌的这张卡的前提下，只要素材组中存在我方场上的怪兽（或素材组为空），就允许手牌的这张卡作为连接素材。
function c53782828.matval(e,lc,mg,c,tp)
	if not lc:IsSetCard(0x156) then return false,nil end
	return true,not mg or mg:IsExists(c53782828.mfilter,1,nil,tp) and not mg:IsExists(c53782828.exmfilter,1,nil)
end
-- ②效果的发动条件：当前阶段为自己或对方的主要阶段（PHASE_MAIN1/PHASE_MAIN2），满足“自己·对方的主要阶段才能发动”的要求。
function c53782828.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为主要阶段1或主要阶段2，作为②效果只能在主要阶段发动的判定。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 筛选函数：从手牌中选出满足“2星以上”“治安战警队”字段，且能够被当前效果特殊召唤的怪兽。
function c53782828.spfilter(c,e,tp)
	return c:IsSetCard(0x156) and c:IsLevelAbove(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标/条件判定：在发动时确认有可用怪兽区域、这张卡能返回手牌且手牌存在可特殊召唤的「治安战警队」怪兽，并登记特殊召唤与回手牌的操作信息。
function c53782828.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 处理发动时的合法性检查：场上存在可用的怪兽区域，且这张卡能够返回持有者手牌。
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToHand()
		-- 并且手牌中存在至少1只满足条件的「治安战警队」怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c53782828.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：本连锁将从手牌把1只怪兽特殊召唤（对象在效果处理时确定，因此 targets 为 nil，数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND)
	-- 登记操作信息：本连锁将发动效果的这张卡返回持有者手牌（目标确定为本卡）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ②效果处理：这张卡返回持有者手牌；若返回成功且这张卡在手牌，并且仍有可用怪兽区域，则从手牌选1只符合条件的「治安战警队」怪兽以表侧表示特殊召唤。
function c53782828.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 检查效果处理时这张卡是否成功返回手牌（若送返成功且仍位于手牌则继续处理）。
	if Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND)
		-- 并且确认自己场上仍有可用的怪兽区域，以进行后续特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向操作玩家显示“请选择要特殊召唤的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌选择1只满足2星以上「治安战警队」字段且可特殊召唤的怪兽。
		local g=Duel.SelectMatchingCard(tp,c53782828.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选择的怪兽以表侧表示形式特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
