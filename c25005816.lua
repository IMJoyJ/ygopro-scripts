--鼓舞
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升700。
function c25005816.initial_effect(c)
	-- 创建效果对象e1，设置其分类为攻击变化，类型为发动效果，属性为取对象效果和伤害步骤效果，代码为自由连锁，提示时点为伤害步骤，条件为aux.dscon，目标函数为c25005816.target，发动函数为c25005816.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c25005816.target)
	e1:SetOperation(c25005816.activate)
	c:RegisterEffect(e1)
end
-- 目标选择函数，用于选择自己场上表侧表示的怪兽
function c25005816.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查是否满足选择目标的条件，即自己场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个自己场上的表侧表示怪兽作为目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 发动函数，用于处理效果的发动和执行
function c25005816.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为选中的怪兽增加700攻击力，直到回合结束时重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(700)
		tc:RegisterEffect(e1)
	end
end
