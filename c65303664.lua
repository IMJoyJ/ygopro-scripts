--森の狩人イエロー・バブーン
-- 效果：
-- 自己场上存在的兽族怪兽被战斗破坏并送去墓地时，可以把自己墓地存在的2只兽族怪兽从游戏中除外。这张卡从手卡特殊召唤。
function c65303664.initial_effect(c)
	-- 自己场上存在的兽族怪兽被战斗破坏并送去墓地时，可以把自己墓地存在的2只兽族怪兽从游戏中除外。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65303664,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c65303664.condition)
	e1:SetCost(c65303664.cost)
	e1:SetTarget(c65303664.target)
	e1:SetOperation(c65303664.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查被战斗破坏并送去墓地的卡是否为自己场上表侧表示存在的兽族怪兽
function c65303664.cfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_BEAST) and c:IsReason(REASON_BATTLE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousRaceOnField(),RACE_BEAST)~=0
end
-- 触发条件：检查被战斗破坏送去墓地的卡片中是否存在满足过滤条件的卡
function c65303664.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c65303664.cfilter,1,nil,tp)
end
-- 过滤条件：检查自己墓地中是否存在可以作为代价除外的兽族怪兽
function c65303664.rfiletr(c)
	return c:IsRace(RACE_BEAST) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：检查并从自己墓地中选择2只兽族怪兽表侧表示除外
function c65303664.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少2只可以作为代价除外的兽族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c65303664.rfiletr,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2只满足条件的兽族怪兽
	local g=Duel.SelectMatchingCard(tp,c65303664.rfiletr,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选择的2只兽族怪兽作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的目标处理：检查自身是否可以特殊召唤以及怪兽区域是否有空位
function c65303664.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果的运行处理：将手牌中的这张卡特殊召唤
function c65303664.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
