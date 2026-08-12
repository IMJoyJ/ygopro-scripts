--恐撃
-- 效果：
-- ①：把自己墓地2只怪兽除外，以场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成0。
function c51099515.initial_effect(c)
	-- 创建效果对象，设置为魔法卡发动效果，具有取对象和伤害步骤发动属性
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c51099515.cost)
	e1:SetTarget(c51099515.target)
	e1:SetOperation(c51099515.activate)
	c:RegisterEffect(e1)
end
-- 过滤器函数，用于判断是否为可作为除外代价的怪兽
function c51099515.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 费用处理函数，检查并选择2只墓地怪兽除外作为代价
function c51099515.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c51099515.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2张墓地怪兽卡
	local cg=Duel.SelectMatchingCard(tp,c51099515.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的卡除外作为发动代价
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
end
-- 目标过滤器函数，用于筛选场上的表侧攻击表示且攻击力大于0的怪兽
function c51099515.tfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:GetAttack()>0
end
-- 效果目标选择函数，选择符合条件的场上怪兽作为对象
function c51099515.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c51099515.tfilter(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c51099515.tfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的场上怪兽作为效果对象
	Duel.SelectTarget(tp,c51099515.tfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果发动处理函数，将目标怪兽攻击力变为0
function c51099515.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽的攻击力设为0直到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
