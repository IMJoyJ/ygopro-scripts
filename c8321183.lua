--霊獣の誓還
-- 效果：
-- ①：从手卡把1只「灵兽」怪兽除外，以自己的墓地·除外状态的1只「灵兽」怪兽为对象才能发动。那只怪兽特殊召唤。
function c8321183.initial_effect(c)
	-- ①：从手卡把1只「灵兽」怪兽除外，以自己的墓地·除外状态的1只「灵兽」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c8321183.cost)
	e1:SetTarget(c8321183.target)
	e1:SetOperation(c8321183.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡中可以作为发动代价除外的「灵兽」怪兽
function c8321183.cfilter(c)
	return c:IsSetCard(0xb5) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 发动代价处理：从手卡将1只「灵兽」怪兽除外
function c8321183.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手卡中是否存在至少1只满足除外条件的「灵兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c8321183.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡选择1只满足条件的「灵兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c8321183.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：自己墓地或除外状态（表侧表示）的可以特殊召唤的「灵兽」怪兽
function c8321183.filter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0xb5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的目标选择处理：选择自己墓地或除外状态的1只「灵兽」怪兽为对象
function c8321183.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c8321183.filter(chkc,e,tp) end
	-- 在发动阶段检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己的墓地或除外状态是否存在至少1只可以特殊召唤的「灵兽」怪兽
		and Duel.IsExistingTarget(c8321183.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地或除外状态的1只「灵兽」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c8321183.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含特殊召唤1个对象的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：将作为对象的怪兽特殊召唤
function c8321183.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
