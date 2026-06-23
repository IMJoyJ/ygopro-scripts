--ロケット・ジャンパー
-- 效果：
-- 当对方场上只有守备表示的怪兽存在时，这张卡可以对对方进行直接攻击。
function c53890795.initial_effect(c)
	-- 当对方场上只有守备表示的怪兽存在时，这张卡可以对对方进行直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c53890795.dircon)
	c:RegisterEffect(e1)
end
-- 判断条件函数，用于确定是否满足直接攻击的条件
function c53890795.dircon(e)
	local tp=e:GetHandler():GetControler()
	-- 检查对方场上是否存在魔陷区的卡片
	return Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)==0
		-- 检查对方场上是否存在攻击表示的怪兽
		and not Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil)
end
