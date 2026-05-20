--火口に潜む者
-- 效果：
-- 当这张卡从场上被破坏送去墓地时，可以从手卡特殊召唤1只炎族怪兽上场。
function c78243409.initial_effect(c)
	-- 当这张卡从场上被破坏送去墓地时，可以从手卡特殊召唤1只炎族怪兽上场。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78243409,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c78243409.condition)
	e1:SetTarget(c78243409.target)
	e1:SetOperation(c78243409.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：这张卡必须在场上被破坏并送去墓地
function c78243409.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：手牌中可以特殊召唤的炎族怪兽
function c78243409.filter(c,e,sp)
	return c:IsRace(RACE_PYRO) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果发动阶段：检查怪兽区域空位以及手牌中是否存在可特殊召唤的炎族怪兽，并设置操作信息
function c78243409.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手牌中是否存在至少1只满足特殊召唤条件的炎族怪兽
		and Duel.IsExistingMatchingCard(c78243409.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理阶段：从手牌选择1只炎族怪兽在自己场上表侧表示特殊召唤
function c78243409.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只满足条件的炎族怪兽
	local g=Duel.SelectMatchingCard(tp,c78243409.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽在自己场上以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
