--CNo.32 海咬龍シャーク・ドレイク・バイス
-- 效果：
-- 水属性4星怪兽×4
-- 这张卡也能在自己场上的「No.32 海咬龙 鲨龙兽」上面重叠来超量召唤。
-- ①：自己·对方回合，自己基本分是1000以下的场合，从自己墓地把1只怪兽除外，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到自己回合的结束时变成0。
function c49221191.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),4,4,c49221191.ovfilter,aux.Stringid(49221191,0))  --"是否要在「No.32 海咬龙 鲨龙兽」上面把这张卡叠放超量召唤？"
	-- 效果原文内容：①：自己·对方回合，自己基本分是1000以下的场合，从自己墓地把1只怪兽除外，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到自己回合的结束时变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49221191,1))  --"攻击变化"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c49221191.condition)
	e1:SetCost(c49221191.cost)
	e1:SetTarget(c49221191.target)
	e1:SetOperation(c49221191.operation)
	c:RegisterEffect(e1)
end
-- 设置此卡为No.32系列怪兽
aux.xyz_number[49221191]=32
-- 过滤满足条件的「No.32 海咬龙 鲨龙兽」，用于超量召唤的条件判断
function c49221191.ovfilter(c)
	return c:IsFaceup() and c:IsCode(65676461)
end
-- 效果发动条件：当前玩家基本分不超过1000且不在伤害步骤后
function c49221191.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前玩家基本分不超过1000
	return Duel.GetLP(tp)<=1000 and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤满足条件的墓地怪兽，用于除外作为代价
function c49221191.rfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动费用：检查是否能从场上取除1个超量素材并从墓地选择1只怪兽除外
function c49221191.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		-- 从墓地选择1只怪兽除外作为效果发动的费用
		and Duel.IsExistingMatchingCard(c49221191.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的墓地怪兽进行除外
	local g=Duel.SelectMatchingCard(tp,c49221191.rfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤满足条件的场上表侧表示怪兽，用于效果对象的选择
function c49221191.filter(c)
	return c:IsFaceup() and (c:GetAttack()>0 or c:GetDefense()>0)
end
-- 设置效果目标：选择1只场上表侧表示且攻击力或守备力大于0的怪兽
function c49221191.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c49221191.filter(chkc) end
	-- 检查是否存在满足条件的场上表侧表示怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c49221191.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要发动效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只满足条件的场上表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c49221191.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：将选中怪兽的攻击力和守备力变为0直到回合结束
function c49221191.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 设置效果：使目标怪兽的攻击力变为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
	end
end
