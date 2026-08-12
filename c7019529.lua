--空の昆虫兵
-- 效果：
-- 攻击风属性的怪兽时，伤害阶段时攻击力上升1000。
function c7019529.initial_effect(c)
	-- 攻击风属性的怪兽时，伤害阶段时攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c7019529.condtion)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
end
-- 设置效果生效的条件：在伤害阶段，自身攻击表侧表示的风属性怪兽时
function c7019529.condtion(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		-- 判断当前进行攻击的怪兽是否为自身，且存在攻击对象
		and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil
		-- 判断攻击对象是否为表侧表示的风属性怪兽
		and Duel.GetAttackTarget():IsFaceup() and Duel.GetAttackTarget():IsAttribute(ATTRIBUTE_WIND)
end
