--水精鱗－ガイオアビス
-- 效果：
-- 水属性7星怪兽×2
-- 只要持有超量素材的这张卡在场上表侧表示存在，5星以上的怪兽不能攻击。此外，1回合1次，把这张卡1个超量素材取除才能发动。持有比这张卡的攻击力低的攻击力的对方场上的怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
function c74371660.initial_effect(c)
	-- 添加XYZ召唤手续：用2只水属性7星怪兽进行叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),7,2)
	c:EnableReviveLimit()
	-- 只要持有超量素材的这张卡在场上表侧表示存在，5星以上的怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 过滤场上等级在5星以上的怪兽作为不能攻击的效果对象
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,5))
	e1:SetCondition(c74371660.dscon)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，把这张卡1个超量素材取除才能发动。持有比这张卡的攻击力低的攻击力的对方场上的怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74371660,0))  --"效果无效"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCost(c74371660.cost)
	e2:SetTarget(c74371660.target)
	e2:SetOperation(c74371660.operation)
	c:RegisterEffect(e2)
end
-- 条件函数：检查自身是否持有超量素材
function c74371660.dscon(e)
	return e:GetHandler():GetOverlayCount()~=0
end
-- 代价函数：检查并取除这张卡的1个超量素材
function c74371660.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：筛选对方场上表侧表示、未被无效且攻击力低于指定数值的效果怪兽
function c74371660.filter(c,atk)
	-- 检查卡片是否为未被无效的效果怪兽，且攻击力小于指定数值
	return aux.NegateMonsterFilter(c) and c:GetAttack()<atk
end
-- 目标过滤：检查对方场上是否存在满足条件的怪兽
function c74371660.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备时，检查对方场上是否存在至少1只攻击力低于自身且效果未被无效的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c74371660.filter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
end
-- 效果处理：使对方场上所有攻击力低于自身的怪兽的效果直到回合结束时无效
function c74371660.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取对方场上所有攻击力低于自身且效果未被无效的怪兽
	local g=Duel.GetMatchingGroup(c74371660.filter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
	local tc=g:GetFirst()
	while tc do
		-- 持有比这张卡的攻击力低的攻击力的对方场上的怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 持有比这张卡的攻击力低的攻击力的对方场上的怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 使目标怪兽在当前连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		tc=g:GetNext()
	end
end
