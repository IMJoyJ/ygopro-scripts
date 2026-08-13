--闇の住人 シャドウキラー
-- 效果：
-- 对方的怪兽卡区域只有守备表示怪兽的场合，这张卡可以直接攻击对方玩家。
function c20939559.initial_effect(c)
	-- 对方的怪兽卡区域只有守备表示怪兽的场合，这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c20939559.con)
	c:RegisterEffect(e1)
end
-- 设置直接攻击效果的发动条件：检查对方场上是否存在攻击表示怪兽，若不存在则条件满足。
function c20939559.con(e)
	-- 对方主要怪兽区不存在攻击表示怪兽时返回 true，即“对方怪兽区域只有守备表示怪兽”的条件成立；否则返回 false。
	return not Duel.IsExistingMatchingCard(Card.IsAttackPos,e:GetHandler():GetControler(),0,LOCATION_MZONE,1,nil)
end
