--騎甲虫アームド・ホーン
-- 效果：
-- 昆虫族怪兽2只
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己不是昆虫族怪兽不能特殊召唤。
-- ②：自己主要阶段才能发动。进行1只昆虫族怪兽的召唤。
-- ③：这张卡在墓地存在的场合，从自己墓地把3只其他的昆虫族怪兽除外才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c2834264.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2只满足种族为昆虫族的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_INSECT),2,2)
	-- 只要这张卡在怪兽区域存在，自己不是昆虫族怪兽不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	-- 筛选目标为非昆虫族的怪兽
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsRace),RACE_INSECT))
	c:RegisterEffect(e1)
	-- 自己主要阶段才能发动。进行1只昆虫族怪兽的召唤
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,2834264)
	e2:SetTarget(c2834264.target)
	e2:SetOperation(c2834264.operation)
	c:RegisterEffect(e2)
	-- 这张卡在墓地存在的场合，从自己墓地把3只其他的昆虫族怪兽除外才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,2834265)
	e3:SetCost(c2834264.spcost)
	e3:SetTarget(c2834264.sptg)
	e3:SetOperation(c2834264.spop)
	c:RegisterEffect(e3)
end
-- 过滤满足种族为昆虫族且可以通常召唤的怪兽
function c2834264.filter(c)
	return c:IsRace(RACE_INSECT) and c:IsSummonable(true,nil)
end
-- 检查场上或手牌中是否存在满足条件的怪兽
function c2834264.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上或手牌中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c2834264.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置连锁操作信息为召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 选择满足条件的怪兽并进行通常召唤
function c2834264.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,c2834264.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		-- 进行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 过滤满足种族为昆虫族且可以作为除外代价的怪兽
function c2834264.cfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- 检查墓地是否存在3只满足条件的怪兽并选择除外
function c2834264.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查墓地是否存在3只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c2834264.cfilter,tp,LOCATION_GRAVE,0,3,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择3只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c2834264.cfilter,tp,LOCATION_GRAVE,0,3,3,c)
	-- 将选中的怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检查是否有足够的召唤位置并可以特殊召唤
function c2834264.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 将卡片特殊召唤并设置其离场时除外的效果
function c2834264.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否可以特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 设置特殊召唤后离场时除外的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
