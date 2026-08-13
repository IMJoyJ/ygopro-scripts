--ローンファイア・ブロッサム
-- 效果：
-- ①：1回合1次，把自己场上1只表侧表示的植物族怪兽解放才能发动。从卡组把1只植物族怪兽特殊召唤。
function c48686504.initial_effect(c)
	-- ①：1回合1次，把自己场上1只表侧表示的植物族怪兽解放才能发动。从卡组把1只植物族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48686504,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c48686504.cost)
	e1:SetTarget(c48686504.target)
	e1:SetOperation(c48686504.operation)
	c:RegisterEffect(e1)
end
-- 筛选解放候选：怪兽必须表侧表示且为植物族，并确认解放后自己场上仍有可用怪兽区域。
function c48686504.costfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
		-- 确认解放该怪兽后自己场上仍有空的怪兽区域，保证后续特殊召唤能够进行。
		and Duel.GetMZoneCount(tp,c,tp)>0
end
-- 发动代价的处理：从自己场上选择并解放1只表侧表示的植物族怪兽，作为效果的发动代价。
function c48686504.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查自己场上是否存在至少1只满足解放条件的表侧表示植物族怪兽，即代价是否能够支付。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c48686504.costfilter,1,nil,tp) end
	-- 从自己场上选择1只满足条件的表侧表示植物族怪兽（costfilter），作为要解放的对象。
	local g=Duel.SelectReleaseGroup(tp,c48686504.costfilter,1,1,nil,tp)
	-- 将选择的植物族怪兽解放，解放原因记为REASON_COST，作为发动该效果的代价。
	Duel.Release(g,REASON_COST)
end
-- 筛选卡组中的怪兽：必须是植物族，并且能够通过当前效果以表侧表示特殊召唤。
function c48686504.filter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标处理：检查卡组中是否存在符合条件的植物族怪兽，并登记特殊召唤的操作信息。
function c48686504.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1只符合条件的植物族怪兽，决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c48686504.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次效果将进行的操作为从卡组特殊召唤1只怪兽，位置为卡组，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果处理时的实际动作：从卡组选择1只植物族怪兽并进行特殊召唤。
function c48686504.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认自己场上有可用的怪兽区域，若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家显示特殊召唤的选择提示，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只符合条件的植物族怪兽作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c48686504.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的植物族怪兽以表侧表示特殊召唤到自己场上（攻击表示）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
