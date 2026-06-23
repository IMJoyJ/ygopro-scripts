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
-- 计算攻击力时调用的函数
function c1434352.atkval(e,c)
	-- 检索自己墓地中怪兽卡的数量并乘以300作为攻击力
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)*300
end
