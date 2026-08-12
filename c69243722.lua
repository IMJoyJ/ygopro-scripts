--ジェムナイト・エメラル
-- 效果：
-- ①：把自己场上1只表侧表示的通常怪兽和这张卡除外，以自己墓地1只「宝石骑士」融合怪兽为对象才能发动。那只怪兽特殊召唤。
function c69243722.initial_effect(c)
	-- ①：把自己场上1只表侧表示的通常怪兽和这张卡除外，以自己墓地1只「宝石骑士」融合怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69243722,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c69243722.cost)
	e1:SetTarget(c69243722.target)
	e1:SetOperation(c69243722.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示、可以作为代价除外的通常怪兽
function c69243722.costfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：检查自身是否能作为代价除外，以及场上是否存在另一只可除外的通常怪兽
function c69243722.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自己场上是否存在至少1只除这张卡以外满足过滤条件的卡
		and Duel.IsExistingMatchingCard(c69243722.costfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1只除这张卡以外满足过滤条件的通常怪兽
	local rg=Duel.SelectMatchingCard(tp,c69243722.costfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	rg:AddCard(e:GetHandler())
	-- 将选中的通常怪兽和这张卡作为发动代价表侧表示除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 过滤条件：自己墓地的「宝石骑士」融合怪兽，且可以特殊召唤
function c69243722.filter(c,e,tp)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的目标选择：检查并选择自己墓地1只「宝石骑士」融合怪兽作为对象，并设置特殊召唤的操作信息
function c69243722.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c69243722.filter(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1只满足过滤条件的对象
	if chk==0 then return Duel.IsExistingTarget(c69243722.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足过滤条件的「宝石骑士」融合怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c69243722.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含特殊召唤的对象和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将作为对象的怪兽特殊召唤
function c69243722.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
