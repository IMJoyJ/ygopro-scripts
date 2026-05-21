--フェニキシアン・シード
-- 效果：
-- 把自己场上表侧表示存在的这张卡送去墓地发动。从自己手卡把1只「凤凰石蒜花」特殊召唤。
function c96553688.initial_effect(c)
	-- 把自己场上表侧表示存在的这张卡送去墓地发动。从自己手卡把1只「凤凰石蒜花」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96553688,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c96553688.cost)
	e1:SetTarget(c96553688.target)
	e1:SetOperation(c96553688.operation)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理：检查自身是否能作为代价送去墓地，并在发动时将自身送去墓地
function c96553688.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡名为「凤凰石蒜花」且可以无视召唤条件特殊召唤的怪兽
function c96553688.filter(c,e,tp)
	return c:IsCode(23558733) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 发动准备（Target）处理：检查怪兽区域空位以及手牌中是否存在可特殊召唤的「凤凰石蒜花」，并设置特殊召唤的操作信息
function c96553688.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确保自身送去墓地后，场上有至少1个空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 且手牌中存在至少1只满足过滤条件的「凤凰石蒜花」
		and Duel.IsExistingMatchingCard(c96553688.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理（Operation）：从手牌选择1只「凤凰石蒜花」特殊召唤
function c96553688.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足过滤条件的「凤凰石蒜花」
	local g=Duel.SelectMatchingCard(tp,c96553688.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示、无视召唤条件特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
