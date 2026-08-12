--ジェムナイト・アレキサンド
-- 效果：
-- ①：把这张卡解放才能发动。从卡组把1只「宝石骑士」通常怪兽特殊召唤。
function c90019393.initial_effect(c)
	-- ①：把这张卡解放才能发动。从卡组把1只「宝石骑士」通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90019393,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c90019393.cost)
	e1:SetTarget(c90019393.target)
	e1:SetOperation(c90019393.operation)
	c:RegisterEffect(e1)
end
-- 发动代价：检查并解放自身
function c90019393.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中可以特殊召唤的「宝石骑士」通常怪兽
function c90019393.filter(c,e,tp)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的目标处理：检查卡组中是否存在符合条件的怪兽，并设置特殊召唤的操作信息
function c90019393.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可以特殊召唤的「宝石骑士」通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90019393.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只「宝石骑士」通常怪兽特殊召唤
function c90019393.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的「宝石骑士」通常怪兽
	local g=Duel.SelectMatchingCard(tp,c90019393.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
