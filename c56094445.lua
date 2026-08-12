--古代の機械兵士
-- 效果：
-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
function c56094445.initial_effect(c)
	-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c56094445.aclimit)
	e1:SetCondition(c56094445.actcon)
	c:RegisterEffect(e1)
end
-- 限制发动的卡片类型为魔法·陷阱卡的发动
function c56094445.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断效果生效的条件函数，即当前攻击的怪兽是否为这张卡自身
function c56094445.actcon(e)
	-- 判断当前攻击的怪兽是否是此卡自身
	return Duel.GetAttacker()==e:GetHandler()
end
