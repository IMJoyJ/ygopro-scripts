--ザ・キャリブレーター
-- 效果：
-- 这张卡的攻击力上升对方场上的超量怪兽的阶级合计×300的数值。
function c54706054.initial_effect(c)
	-- 这张卡的攻击力上升对方场上的超量怪兽的阶级合计×300的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c54706054.atkval)
	c:RegisterEffect(e1)
end
-- 计算对方场上表侧表示怪兽的阶级合计并乘以300，作为攻击力上升的数值（非超量怪兽的阶级为0）。
function c54706054.atkval(e,c)
	-- 获取对方场上所有表侧表示的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,c:GetControler(),0,LOCATION_MZONE,nil)
	return g:GetSum(Card.GetRank)*300
end
