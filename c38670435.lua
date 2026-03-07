--暗黒恐獣
-- 效果：
-- 当对方场上仅有守备表示的怪兽存在时，这张卡可以对对方进行直接攻击。
function c38670435.initial_effect(c)
	-- 效果原文内容：当对方场上仅有守备表示的怪兽存在时，这张卡可以对对方进行直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c38670435.dircon)
	c:RegisterEffect(e1)
end
-- 规则层面操作：判断是否满足直接攻击的条件
function c38670435.dircon(e)
	local tp=e:GetHandler():GetControler()
	-- 规则层面操作：检查对方场上是否存在魔法或陷阱怪兽
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_MZONE,1,nil,TYPE_SPELL+TYPE_TRAP)
		-- 规则层面操作：检查对方场上是否存在攻击表示的怪兽
		and not Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil)
end
