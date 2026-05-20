--ザ・アキュムレーター
-- 效果：
-- ①：这张卡的攻击力上升场上的连接怪兽的连接标记数量×300。
function c70410002.initial_effect(c)
	-- ①：这张卡的攻击力上升场上的连接怪兽的连接标记数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c70410002.atkval)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示的连接怪兽
function c70410002.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 计算并返回场上所有表侧表示连接怪兽的连接标记数量之和乘以300的数值
function c70410002.atkval(e,c)
	-- 获取双方场上所有表侧表示的连接怪兽
	local g=Duel.GetMatchingGroup(c70410002.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	return g:GetSum(Card.GetLink)*300
end
