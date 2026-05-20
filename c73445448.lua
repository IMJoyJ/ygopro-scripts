--No.22 不乱健
-- 效果：
-- 暗属性8星怪兽×2
-- 这张卡不用超量召唤不能特殊召唤。
-- ①：1回合1次，这张卡在场上攻击表示存在的场合，把这张卡1个超量素材取除，把1张手卡送去墓地，以对方场上1张表侧表示的卡为对象才能发动。这张卡变成守备表示，作为对象的卡的效果直到回合结束时无效。这个效果在对方回合也能发动。
function c73445448.initial_effect(c)
	-- 添加XYZ召唤手续：暗属性8星怪兽×2。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),8,2)
	c:EnableReviveLimit()
	-- 这张卡不用超量召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为仅能进行XYZ召唤。
	e1:SetValue(aux.xyzlimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，这张卡在场上攻击表示存在的场合，把这张卡1个超量素材取除，把1张手卡送去墓地，以对方场上1张表侧表示的卡为对象才能发动。这张卡变成守备表示，作为对象的卡的效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73445448,0))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c73445448.cost)
	e2:SetTarget(c73445448.target)
	e2:SetOperation(c73445448.operation)
	c:RegisterEffect(e2)
end
-- 设定该卡片的No.编号为22。
aux.xyz_number[73445448]=22
-- 检查发动代价：是否能取除自身1个超量素材，且手牌中是否存在可以送去墓地的卡。
function c73445448.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		-- 检查手牌中是否存在至少1张可以作为代价送去墓地的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 玩家选择1张手牌作为发动代价送去墓地。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 检查发动条件与目标：自身是否为攻击表示，对方场上是否存在可以被无效的表侧表示卡片，并进行取对象操作。
function c73445448.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查已选择的对象是否为对方场上可以被无效的卡。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	if chk==0 then return e:GetHandler():IsAttackPos()
		-- 检查对方场上是否存在至少1张可以被无效的表侧表示卡片。
		and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择对方场上1张表侧表示的卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：使对象卡片效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理：自身变成守备表示，并将作为对象的卡的效果直到回合结束时无效。
function c73445448.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsDefensePos() then return end
	-- 将自身变成表侧守备表示。
	Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)
	-- 获取效果发动的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与对象卡片相关的连锁都无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 作为对象的卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 作为对象的卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 作为对象的卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
