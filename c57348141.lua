--トワイライト・イレイザー
-- 效果：
-- ①：自己场上有相同种族而卡名不同的「光道」怪兽2只以上存在的场合，把自己墓地2只「光道」怪兽除外，以场上2张卡为对象才能发动。那些卡除外。
-- ②：这张卡被「光道」怪兽的效果从卡组送去墓地的场合才能发动。从手卡把1只「光道」怪兽特殊召唤。
function c57348141.initial_effect(c)
	-- ①：自己场上有相同种族而卡名不同的「光道」怪兽2只以上存在的场合，把自己墓地2只「光道」怪兽除外，以场上2张卡为对象才能发动。那些卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c57348141.condition)
	e1:SetCost(c57348141.cost)
	e1:SetTarget(c57348141.target)
	e1:SetOperation(c57348141.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被「光道」怪兽的效果从卡组送去墓地的场合才能发动。从手卡把1只「光道」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c57348141.spcon)
	e2:SetTarget(c57348141.sptg)
	e2:SetOperation(c57348141.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否存在表侧表示的「光道」怪兽，且场上存在另一只与其种族相同但卡名不同的「光道」怪兽
function c57348141.filter1(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x38)
		-- 检查场上是否存在另一只与当前怪兽种族相同但卡名不同的「光道」怪兽
		and Duel.IsExistingMatchingCard(c57348141.filter2,tp,LOCATION_MZONE,0,1,c,c:GetRace(),c:GetCode())
end
-- 过滤函数：用于匹配与指定怪兽种族相同但卡名不同的表侧表示「光道」怪兽
function c57348141.filter2(c,race,code)
	return c:IsFaceup() and c:IsSetCard(0x38) and c:IsRace(race) and not c:IsCode(code)
end
-- 发动条件判定
function c57348141.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足相同种族且卡名不同的「光道」怪兽2只以上
	return Duel.IsExistingMatchingCard(c57348141.filter1,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 过滤函数：用于匹配墓地中可以作为除外代价的「光道」怪兽
function c57348141.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x38) and c:IsAbleToRemoveAsCost()
end
-- 发动代价处理
function c57348141.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查墓地是否存在至少2只「光道」怪兽作为除外代价
	if chk==0 then return Duel.IsExistingMatchingCard(c57348141.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 给玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2只「光道」怪兽
	local g=Duel.SelectMatchingCard(tp,c57348141.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的2只怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 发动效果的目标选择与效果分类设置
function c57348141.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() and chkc:IsAbleToRemove() end
	-- 在发动阶段检查场上是否存在至少2张可以除外的卡（不包括这张卡自身）
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,e:GetHandler()) end
	-- 给玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择场上2张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,e:GetHandler())
	-- 设置连锁信息：此效果包含除外场上2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理函数
function c57348141.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与此效果相关的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将这些对象卡片表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 特殊召唤效果的发动条件判定：这张卡被「光道」怪兽的效果从卡组送去墓地
function c57348141.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK) and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x38)
		and bit.band(r,REASON_EFFECT)~=0
end
-- 过滤函数：用于匹配手卡中可以特殊召唤的「光道」怪兽
function c57348141.spfilter(c,e,tp)
	return c:IsSetCard(0x38) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标选择与效果分类设置
function c57348141.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡中存在至少1只可以特殊召唤的「光道」怪兽
		and Duel.IsExistingMatchingCard(c57348141.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息：此效果包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的处理函数
function c57348141.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足特殊召唤条件的「光道」怪兽
	local g=Duel.SelectMatchingCard(tp,c57348141.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
