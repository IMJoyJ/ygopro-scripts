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
-- 定义攻击力数值计算函数：取自己场上表侧表示怪兽的等级合计，再乘以300作为这张卡的攻击力。
function c51196174.atkval(e,c)
	-- 获取自己场上全部表侧表示怪兽，组成一个卡组对象g，用于后续统计等级合计。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,c:GetControler(),LOCATION_MZONE,0,nil)
	return g:GetSum(Card.GetLevel)*300
end
