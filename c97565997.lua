--溟界神－オグドアビス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的场合，把自己场上3只怪兽解放才能发动。这张卡特殊召唤。
-- ②：只在这张卡在场上表侧表示存在才能发动1次。除从墓地特殊召唤的表侧表示怪兽以外的自己·对方场上的怪兽全部送去墓地。这个效果在对方回合也能发动。
function c97565997.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，把自己场上3只怪兽解放才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97565997,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,97565997)
	e1:SetCost(c97565997.spcost)
	e1:SetTarget(c97565997.sptg)
	e1:SetOperation(c97565997.spop)
	c:RegisterEffect(e1)
	-- ②：只在这张卡在场上表侧表示存在才能发动1次。除从墓地特殊召唤的表侧表示怪兽以外的自己·对方场上的怪兽全部送去墓地。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97565997,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,97565998)
	e2:SetTarget(c97565997.tgtg)
	e2:SetOperation(c97565997.tgop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动代价（Cost）：解放自己场上的3只怪兽
function c97565997.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可解放的怪兽卡组
	local g=Duel.GetReleaseGroup(tp)
	-- 在chk==0时，检查是否能选出3只满足解放后仍有空位特殊召唤等条件的怪兽
	if chk==0 then return g:CheckSubGroup(aux.mzctcheckrel,3,3,tp) end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择3只满足解放后仍有空位特殊召唤等条件的怪兽
	local rg=g:SelectSubGroup(tp,aux.mzctcheckrel,false,3,3,tp)
	-- 应用代替解放效果的次数限制（如暗影敌托邦等效果）
	aux.UseExtraReleaseCount(rg,tp)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(rg,REASON_COST)
end
-- ①号效果的发动准备（Target）：检查自身是否能特殊召唤并设置特殊召唤的操作信息
function c97565997.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的效果处理（Operation）：将自身特殊召唤
function c97565997.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤出非“从墓地特殊召唤的表侧表示怪兽”且能送去墓地的怪兽
function c97565997.tgfilter(c)
	return not (c:IsFaceup() and c:IsSummonLocation(LOCATION_GRAVE) and c:GetOriginalType()&TYPE_MONSTER~=0) and c:IsAbleToGrave()
end
-- ②号效果的发动准备（Target）：检查场上是否存在满足条件的怪兽并设置送去墓地的操作信息
function c97565997.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上满足送去墓地过滤条件的怪兽
	local g=Duel.GetMatchingGroup(c97565997.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 设置将这些怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
-- ②号效果的效果处理（Operation）：将符合条件的怪兽全部送去墓地
function c97565997.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取双方场上满足送去墓地过滤条件的怪兽
	local g=Duel.GetMatchingGroup(c97565997.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		-- 将符合条件的怪兽全部送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
