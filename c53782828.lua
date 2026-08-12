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
-- 过滤函数，用于判断场上是否有自己控制的怪兽
function c53782828.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 过滤函数，用于判断手卡中是否存在这张卡
function c53782828.exmfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsCode(53782828)
end
-- 连接素材的判断函数，用于判断是否可以将手卡的这张卡作为连接素材
function c53782828.matval(e,lc,mg,c,tp)
	if not lc:IsSetCard(0x156) then return false,nil end
	return true,not mg or mg:IsExists(c53782828.mfilter,1,nil,tp) and not mg:IsExists(c53782828.exmfilter,1,nil)
end
-- 效果发动的条件判断函数，用于判断是否处于主要阶段
function c53782828.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤函数，用于筛选手卡中2星以上的治安战警队怪兽
function c53782828.spfilter(c,e,tp)
	return c:IsSetCard(0x156) and c:IsLevelAbove(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动宣言函数，用于判断是否满足发动条件
function c53782828.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有可用怪兽区以及这张卡是否能回到手卡
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToHand()
		-- 判断手卡中是否存在满足条件的治安战警队怪兽
		and Duel.IsExistingMatchingCard(c53782828.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的卡的分类信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND)
	-- 设置效果处理时要将这张卡送回手卡的分类信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果的处理函数，用于执行效果的处理流程
function c53782828.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 判断是否成功将这张卡送回手卡且仍在手卡位置
	if Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND)
		-- 判断场上是否有可用怪兽区
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的治安战警队怪兽
		local g=Duel.SelectMatchingCard(tp,c53782828.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
