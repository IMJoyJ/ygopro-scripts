--単一化
-- 效果：
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。作为对象的怪兽以外的场上的全部怪兽的攻击力直到回合结束时变成和作为对象的怪兽相同。
function c53077251.initial_effect(c)
	-- 创建效果对象，设置为魔法卡发动效果，具有改变攻击力的分类，提示在伤害步骤时点发动，可于自由时点发动，具有取对象和伤害步骤发动的属性，限制发动时机为伤害计算前，设置目标函数和发动函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 限制该效果只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c53077251.target)
	e1:SetOperation(c53077251.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查对方场上是否存在满足条件的表侧表示怪兽，即该怪兽存在至少一张其他场上的表侧表示怪兽的攻击力与它不同
function c53077251.filter(c,tp)
	-- 当前怪兽为表侧表示且对方场上存在至少一张攻击力不同于它的表侧表示怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c53077251.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetAttack())
end
-- 过滤函数：检查是否为表侧表示且攻击力不等于指定值
function c53077251.filter2(c,atk)
	return c:IsFaceup() and not c:IsAttack(atk)
end
-- 设置目标选择函数，当chkc不为空时判断是否满足filter条件；chk==0时判断是否存在满足filter条件的目标怪兽
function c53077251.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53077251.filter(chkc,tp) end
	-- 判断是否存在满足filter条件的对方场上表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c53077251.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 向玩家提示“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,c53077251.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
end
-- 发动函数：获取目标怪兽，若其有效且为表侧表示，则获取其攻击力，并检索所有攻击力不同于它的对方场上表侧表示怪兽，将它们的攻击力设置为与目标怪兽相同
function c53077251.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local atk=tc:GetAttack()
	-- 检索所有攻击力不同于目标怪兽的对方场上表侧表示怪兽
	local g=Duel.GetMatchingGroup(c53077251.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,tc,atk)
	-- 遍历上述怪兽组中的每张怪兽卡
	for sc in aux.Next(g) do
		-- 将攻击力设置为与目标怪兽相同的效果，该效果在回合结束时重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sc:RegisterEffect(e1)
	end
end
