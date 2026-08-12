--魔轟神ソルキウス
-- 效果：
-- ①：这张卡在墓地存在的场合，从手卡把「魔轰神 索尔基乌斯」以外的2张卡送去墓地才能发动。这张卡特殊召唤。
function c72328962.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，从手卡把「魔轰神 索尔基乌斯」以外的2张卡送去墓地才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72328962,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(c72328962.cost)
	e1:SetTarget(c72328962.tg)
	e1:SetOperation(c72328962.op)
	c:RegisterEffect(e1)
end
-- 过滤手牌中「魔轰神 索尔基乌斯」以外且可以作为代价送去墓地的卡片
function c72328962.costfilter(c)
	return not c:IsCode(72328962) and c:IsAbleToGraveAsCost()
end
-- 检查并执行发动代价：从手卡把「魔轰神 索尔基乌斯」以外的2张卡送去墓地
function c72328962.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手牌中是否存在至少2张「魔轰神 索尔基乌斯」以外且可以送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c72328962.costfilter,tp,LOCATION_HAND,0,2,nil) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌选择2张「魔轰神 索尔基乌斯」以外的卡片
	local g=Duel.SelectMatchingCard(tp,c72328962.costfilter,tp,LOCATION_HAND,0,2,2,nil)
	-- 将选择的卡片作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检查自身是否可以特殊召唤，并设置特殊召唤的操作信息
function c72328962.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查己方场上是否有空余的怪兽区域，以及自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若自身仍存在于墓地，则将自身特殊召唤
function c72328962.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
