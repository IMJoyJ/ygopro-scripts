--ローンファイア・ブロッサム
-- 效果：
-- ①：1回合1次，把自己场上1只表侧表示的植物族怪兽解放才能发动。从卡组把1只植物族怪兽特殊召唤。
function c48686504.initial_effect(c)
	-- 效果原文：①：1回合1次，把自己场上1只表侧表示的植物族怪兽解放才能发动。从卡组把1只植物族怪兽特殊召唤。
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
-- 过滤函数：检查场上是否存在满足条件的可解放的植物族怪兽（表侧表示且有可用怪兽区）
function c48686504.costfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
		-- 判断目标怪兽是否拥有可用的怪兽区（即该怪兽解放后不会导致怪兽区不足）
		and Duel.GetMZoneCount(tp,c,tp)>0
end
-- 效果Cost处理：检查并选择1只满足条件的怪兽进行解放
function c48686504.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张满足costfilter条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c48686504.costfilter,1,nil,tp) end
	-- 从场上选择1张满足costfilter条件的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c48686504.costfilter,1,1,nil,tp)
	-- 将选中的怪兽以REASON_COST原因进行解放
	Duel.Release(g,REASON_COST)
end
-- 过滤函数：检查卡组中是否存在可以特殊召唤的植物族怪兽
function c48686504.filter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果Target处理：确认卡组中存在至少1只可特殊召唤的植物族怪兽
function c48686504.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足filter条件的植物族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c48686504.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要从卡组特殊召唤1只植物族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果Operation处理：确认场上存在可用空间后选择并特殊召唤1只植物族怪兽
function c48686504.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有可用的怪兽区（防止无法特殊召唤）
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足filter条件的植物族怪兽
	local g=Duel.SelectMatchingCard(tp,c48686504.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
