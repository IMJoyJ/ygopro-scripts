--CNo.32 海咬龍シャーク・ドレイク・バイス
-- 效果：
-- 水属性4星怪兽×4
-- 这张卡也能在自己场上的「No.32 海咬龙 鲨龙兽」上面重叠来超量召唤。
-- ①：自己·对方回合，自己基本分是1000以下的场合，从自己墓地把1只怪兽除外，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到自己回合的结束时变成0。
function c49221191.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),4,4,c49221191.ovfilter,aux.Stringid(49221191,0))  --"是否要在「No.32 海咬龙 鲨龙兽」上面把这张卡叠放超量召唤？"
	-- ①：自己·对方回合，自己基本分是1000以下的场合，从自己墓地把1只怪兽除外，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到自己回合的结束时变成0。
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
-- 将本卡的XYZ编号设定为32，使本卡在规则上作为「No.32」卡处理。
aux.xyz_number[49221191]=32
-- 判定超量召唤手续中可叠放的素材：自己场上表侧表示且卡名为「No.32 海咬龙 鲨龙兽」（卡号65676461）的卡。
function c49221191.ovfilter(c)
	return c:IsFaceup() and c:IsCode(65676461)
end
-- 定义①效果的发动条件：发动者基本分在1000以下，且满足伤害步骤中可发动效果的时点限制。
function c49221191.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判定：发动者LP≤1000，且当前时点不是伤害计算后，符合伤害步骤的发动限制。
	return Duel.GetLP(tp)<=1000 and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 定义墓地怪兽作为除外代价的过滤条件：必须是怪兽卡且可以作为代价除外。
function c49221191.rfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 定义①的发动代价：取除这张卡的1个超量素材，并从自己墓地除外1只怪兽；chk==0时检查是否满足这些代价条件。
function c49221191.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		-- 检查自己墓地是否存在至少1只满足rfilter条件的怪兽，可供除外作为代价。
		and Duel.IsExistingMatchingCard(c49221191.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 显示『请选择要除外的卡』的提示，让玩家选择要除外的墓地怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地的怪兽中选择1张作为代价，存入组g。
	local g=Duel.SelectMatchingCard(tp,c49221191.rfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的墓地怪兽以表侧表示除外，作为效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义效果对象的选择条件：场上表侧表示怪兽，且攻击力或守备力至少一项大于0。
function c49221191.filter(c)
	return c:IsFaceup() and (c:GetAttack()>0 or c:GetDefense()>0)
end
-- 定义①的取对象处理：选择场上1只表侧表示且攻击力/守备力有任意一项大于0的怪兽；连锁时检查对象合法性，发动时选择1只。
function c49221191.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c49221191.filter(chkc) end
	-- 判定场上是否存在满足filter条件的表侧表示怪兽可供选择为对象。
	if chk==0 then return Duel.IsExistingTarget(c49221191.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示『请选择表侧表示的卡』的提示，指引玩家选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方场上选择1只表侧表示怪兽作为效果对象，并登记为当前连锁的对象卡。
	Duel.SelectTarget(tp,c49221191.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 定义①效果处理时的操作：在对象卡仍与效果相关且为表侧表示时，将其攻击力和守备力变成0直到自己回合结束。
function c49221191.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁上登记的目标怪兽，即发动时所选择的表侧表示怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力·守备力直到自己回合的结束时变成0。
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
