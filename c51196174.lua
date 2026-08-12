--ザ・カリキュレーター
-- 效果：
-- ①：这张卡的攻击力变成自己场上的怪兽的等级合计×300。
function c51196174.initial_effect(c)
	-- ①：这张卡的攻击力变成自己场上的怪兽的等级合计×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c51196174.atkval)
	c:RegisterEffect(e1)
end
-- 计算满足条件的卡片组中所有怪兽的等级总和并乘以300作为新的攻击力
function c51196174.atkval(e,c)
	-- 检索自己场上所有正面表示存在的怪兽组成卡片组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,c:GetControler(),LOCATION_MZONE,0,nil)
	return g:GetSum(Card.GetLevel)*300
end
