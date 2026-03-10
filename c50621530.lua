--パワード・チューナー
-- 效果：
-- 这张卡的攻击力上升场上表侧表示存在的调整数量×500的数值。
function c50621530.initial_effect(c)
	-- 这张卡的攻击力上升场上表侧表示存在的调整数量×500的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c50621530.atkval)
	c:RegisterEffect(e1)
end
-- 检查目标怪兽是否为表侧表示且类型为调整。
function c50621530.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 计算场上表侧表示的调整数量并乘以500作为攻击力提升值。
function c50621530.atkval(e,c)
	-- 检索满足条件的调整数量并乘以500
	return Duel.GetMatchingGroupCount(c50621530.cfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)*500
end
