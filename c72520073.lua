--闇の芸術家
-- 效果：
-- 受到了光属性怪兽的攻击时，这张卡的守备力成为一半。
function c72520073.initial_effect(c)
	-- 受到了光属性怪兽的攻击时，这张卡的守备力成为一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c72520073.defcon)
	e1:SetValue(c72520073.defval)
	c:RegisterEffect(e1)
end
-- 定义效果生效的条件函数，用于判断是否满足守备力减半的条件
function c72520073.defcon(e)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判断当前是否处于伤害计算阶段、自身是否为攻击对象，且与自身战斗的怪兽是否为光属性
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and c==Duel.GetAttackTarget() and bc:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 定义守备力数值变化函数，计算并返回该卡当前守备力一半的数值（向上取整）
function c72520073.defval(e,c)
	return math.ceil(e:GetHandler():GetDefense()/2)
end
