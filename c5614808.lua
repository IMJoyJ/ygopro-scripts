--白闘気白鯨
-- 效果：
-- 水属性调整＋调整以外的水属性怪兽1只以上
-- ①：这张卡同调召唤时才能发动。对方场上的攻击表示怪兽全部破坏。
-- ②：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ③：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ④：这张卡被对方破坏送去墓地的场合，从自己墓地把1只其他的水属性怪兽除外才能发动。这张卡当作调整使用特殊召唤。
function c5614808.initial_effect(c)
	-- 设置同调召唤手续：水属性调整+1只以上调整以外的水属性怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_WATER),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤时才能发动。对方场上的攻击表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5614808,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c5614808.descon)
	e1:SetTarget(c5614808.destg)
	e1:SetOperation(c5614808.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	-- ④：这张卡被对方破坏送去墓地的场合，从自己墓地把1只其他的水属性怪兽除外才能发动。这张卡当作调整使用特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(5614808,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c5614808.condition)
	e4:SetCost(c5614808.cost)
	e4:SetTarget(c5614808.target)
	e4:SetOperation(c5614808.operation)
	c:RegisterEffect(e4)
end
c5614808.treat_itself_tuner=true
-- 效果①的发动条件：此卡同调召唤成功
function c5614808.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的发动检测：检查对方场上是否存在攻击表示怪兽，并设置破坏效果的操作信息
function c5614808.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只攻击表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的攻击表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏对方场上所有攻击表示怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的效果处理：获取并破坏对方场上所有的攻击表示怪兽
function c5614808.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的攻击表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 破坏获取到的怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果④的发动条件：此卡被对方因战斗或效果破坏并送去墓地
function c5614808.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤条件：墓地中除自身以外的水属性怪兽
function c5614808.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果④的代价处理：从自己墓地把1只其他的水属性怪兽除外
function c5614808.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在除自身以外的、可以除外的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5614808.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地1只其他的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c5614808.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果④的发动检测：检查怪兽区域空位以及自身是否可以特殊召唤，并设置特殊召唤操作信息
function c5614808.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果④的效果处理：特殊召唤自身，并使其当作调整使用
function c5614808.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与效果相关，并尝试将其表侧表示特殊召唤到自己场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这张卡当作调整使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
