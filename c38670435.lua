--暗黒恐獣
-- 效果：
-- 当对方场上仅有守备表示的怪兽存在时，这张卡可以对对方进行直接攻击。
function c38670435.initial_effect(c)
	-- 当对方场上仅有守备表示的怪兽存在时，这张卡可以对对方进行直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c38670435.dircon)
	c:RegisterEffect(e1)
end
-- 定义直接攻击的条件：以我方视角确认对方场上不存在攻击表示怪兽，也不存在魔法·陷阱卡，即对方场上仅存在守备表示怪兽。
function c38670435.dircon(e)
	local tp=e:GetHandler():GetControler()
	-- 检查对方场上（主要怪兽区）是否不存在魔法·陷阱卡，若不存在则满足“仅有守备表示怪兽”的前提之一。
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_MZONE,1,nil,TYPE_SPELL+TYPE_TRAP)
		-- 检查对方场上是否不存在攻击表示怪兽，若不存在则满足“仅有守备表示怪兽”的前提之一。
		and not Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil)
end
