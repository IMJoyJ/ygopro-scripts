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
-- 直接攻击效果的条件判断：以这张卡的控制者为视角，检查对方场上没有魔法陷阱卡，且不存在攻击表示的怪兽（即对方场上怪兽均为守备表示；若对方场上没有怪兽时条件也成立，但此时本就可直接攻击）。
function c53890795.dircon(e)
	local tp=e:GetHandler():GetControler()
	-- 检查对方场上是否存在魔法陷阱卡：以这张卡的控制者为视角，统计对方魔陷区的卡片数量是否为0。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)==0
		-- 且对方场上不存在攻击表示的怪兽：在对方的怪兽区域（主要怪兽区及额外怪兽区）中不存在攻击表示怪兽，确保对方怪兽均为守备表示。
		and not Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil)
end
