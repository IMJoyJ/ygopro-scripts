--騎甲虫アームド・ホーン
-- 效果：
-- 昆虫族怪兽2只
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己不是昆虫族怪兽不能特殊召唤。
-- ②：自己主要阶段才能发动。进行1只昆虫族怪兽的召唤。
-- ③：这张卡在墓地存在的场合，从自己墓地把3只其他的昆虫族怪兽除外才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c2834264.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，素材为2只昆虫族怪兽，对应连接召唤条件“昆虫族怪兽2只”。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_INSECT),2,2)
	-- ①：只要这张卡在怪兽区域存在，自己不是昆虫族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	-- 设置①效果的适用对象，以玩家为对象限制“自己”不能特殊召唤非昆虫族怪兽。
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsRace),RACE_INSECT))
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。进行1只昆虫族怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,2834264)
	e2:SetTarget(c2834264.target)
	e2:SetOperation(c2834264.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的场合，从自己墓地把3只其他的昆虫族怪兽除外才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
-- 定义②效果可选的召唤对象：昆虫族怪兽，且当前可以不占用通常召唤次数地进行通常召唤。
function c2834264.filter(c)
	return c:IsRace(RACE_INSECT) and c:IsSummonable(true,nil)
end
-- ②效果的发动条件判定与操作信息设置：确认存在符合条件的昆虫族怪兽可召唤，并标记此效果将进行召唤。
function c2834264.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查手牌或主要怪兽区域是否存在至少1只满足条件的昆虫族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c2834264.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息，宣告本效果将进行1只怪兽的召唤，供后续时点或相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②效果处理：提示玩家选择要召唤的昆虫族怪兽，并以不占用通常召唤次数的方式将其通常召唤。
function c2834264.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示“请选择要召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌或主要怪兽区域选择1只满足条件的昆虫族怪兽作为召唤对象。
	local tc=Duel.SelectMatchingCard(tp,c2834264.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		-- 无视召唤次数限制，将选择的昆虫族怪兽进行通常召唤。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 定义③效果除外代价的过滤器：墓地中除自身以外的昆虫族怪兽，且可以作为代价除外。
function c2834264.cfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- ③效果发动代价处理：检查并执行从自己墓地除外3只其他昆虫族怪兽作为发动代价。
function c2834264.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检查阶段确认墓地中是否存在至少3只符合条件的其他昆虫族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c2834264.cfilter,tp,LOCATION_GRAVE,0,3,c) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择3只符合条件的昆虫族怪兽（不包括本卡）作为代价。
	local g=Duel.SelectMatchingCard(tp,c2834264.cfilter,tp,LOCATION_GRAVE,0,3,3,c)
	-- 将选中的3只昆虫族怪兽以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③效果发动目标判定：确认自己主要怪兽区域有空位，且这张卡可以特殊召唤。
function c2834264.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，宣告本效果将对这张卡进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ③效果处理：将这张卡特殊召唤，若成功则给它附加“离场时除外”的效果。
function c2834264.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果相关，并将其以表侧表示特殊召唤到自己场上。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
