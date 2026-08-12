--砲撃のカタパルト・タートル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上1只怪兽解放才能发动。从手卡·卡组把1只「暗黑骑士 盖亚」怪兽或者龙族·5星怪兽特殊召唤。
function c7913375.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把自己场上1只怪兽解放才能发动。从手卡·卡组把1只「暗黑骑士 盖亚」怪兽或者龙族·5星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7913375,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,7913375)
	e1:SetCost(c7913375.spcost)
	e1:SetTarget(c7913375.sptg)
	e1:SetOperation(c7913375.spop)
	c:RegisterEffect(e1)
end
-- 解放怪兽的过滤条件（用于检查解放该怪兽后是否有可用的怪兽区域）
function c7913375.rfilter(c,tp)
	-- 检查将该怪兽解放后，玩家场上是否有空余的怪兽区域
	return Duel.GetMZoneCount(tp,c)>0
end
-- 效果发动的代价（Cost）处理函数
function c7913375.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1只满足解放条件且解放后能腾出怪兽区域的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c7913375.rfilter,1,nil,tp) end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择1只满足解放条件的怪兽
	local g=Duel.SelectReleaseGroup(tp,c7913375.rfilter,1,1,nil,tp)
	-- 将选择的怪兽解放作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 过滤手卡·卡组中可以特殊召唤的「暗黑骑士 盖亚」怪兽或5星龙族怪兽
function c7913375.spfilter(c,e,tp)
	return (c:IsSetCard(0xbd) or c:IsLevel(5) and c:IsRace(RACE_DRAGON)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标（Target）检查与设置函数
function c7913375.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或卡组中是否存在至少1只满足特殊召唤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c7913375.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为“从手卡或卡组特殊召唤1只怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理（Operation）函数
function c7913375.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组选择1只满足特殊召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c7913375.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自身场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
