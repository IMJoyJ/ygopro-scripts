--サイバー・チュチュ
-- 效果：
-- ①：对方场上的怪兽只有持有比这张卡高的攻击力的怪兽的场合，这张卡可以向对方直接攻击。
function c49375719.initial_effect(c)
	-- ①：对方场上的怪兽只有持有比这张卡高的攻击力的怪兽的场合，这张卡可以向对方直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c49375719.dacon)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查对方场上是否存在里侧表示或攻击力不大于自身攻击力的怪兽
function c49375719.filter(c,atk)
	return c:IsFacedown() or c:GetAttack()<=atk
end
-- 条件函数，判断是否满足直接攻击的条件
function c49375719.dacon(e)
	-- 检索对方场上是否存在满足filter条件的怪兽，若不存在则可直接攻击
	return not Duel.IsExistingMatchingCard(c49375719.filter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack())
end
