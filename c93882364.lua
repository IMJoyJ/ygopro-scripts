--ジェネクス・ワーカー
-- 效果：
-- ①：把这张卡解放才能发动。从手卡把1只「次世代」怪兽特殊召唤。
function c93882364.initial_effect(c)
	-- ①：把这张卡解放才能发动。从手卡把1只「次世代」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93882364,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c93882364.cost)
	e1:SetTarget(c93882364.target)
	e1:SetOperation(c93882364.operation)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理：检查自身是否可以解放，并解放自身
function c93882364.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：手卡中可以特殊召唤的「次世代」怪兽
function c93882364.filter(c,e,tp)
	return c:IsSetCard(0x2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标确认与操作信息设置
function c93882364.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查怪兽区域的空位数是否大于-1（因为自身解放会空出一个格子）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并且检查手卡中是否存在至少1只可以特殊召唤的「次世代」怪兽
		and Duel.IsExistingMatchingCard(c93882364.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示该效果包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理（Operation）：从手卡选择1只「次世代」怪兽特殊召唤
function c93882364.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，检查自己场上的怪兽区域是否有空位，若没有则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的「次世代」怪兽
	local g=Duel.SelectMatchingCard(tp,c93882364.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽在自己场上以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
