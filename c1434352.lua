--カオス・ネクロマンサー
-- 效果：
-- 这张卡的攻击力为自己墓地里存在的怪兽卡数量×300点的数值。
function c1434352.initial_effect(c)
	-- 这张卡的攻击力为自己墓地里存在的怪兽卡数量×300点的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c1434352.atkval)
	c:RegisterEffect(e1)
end
-- 计算该卡控制者墓地里存在的怪兽卡数量并乘以300，作为该卡当前的攻击力数值。
function c1434352.atkval(e,c)
	-- 统计该卡控制者墓地中的怪兽卡数量，并乘以300得到攻击力数值。
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)*300
end
