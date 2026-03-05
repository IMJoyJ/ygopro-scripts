--ミクロ光線
-- 效果：
-- 使场上1张表侧表示怪兽的守备力变成零直到结束阶段终了时为止。
function c18190572.initial_effect(c)
	-- 创建效果对象并设置其类型为魔法卡发动效果，同时设置提示时点为伤害步骤，属性为取对象效果和伤害步骤可发动，触发条件为自由连锁，发动条件为aux.dscon函数，目标函数为c18190572.target，发动效果函数为c18190572.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 限制效果只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c18190572.target)
	e1:SetOperation(c18190572.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择表侧表示且守备力大于0的怪兽
function c18190572.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 目标选择函数：判断是否为场上的表侧表示怪兽且守备力大于0，若满足条件则选择一个目标
function c18190572.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c18190572.filter(chkc) end
	-- 判断是否满足选择目标的条件：场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c18190572.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上满足条件的1只表侧表示怪兽作为目标
	Duel.SelectTarget(tp,c18190572.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 发动效果函数：获取目标怪兽，若其仍然存在于场且为表侧表示，则将其守备力变为0
function c18190572.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将守备力变为0的效果注册给目标怪兽，该效果在结束阶段结束时重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
	end
end
