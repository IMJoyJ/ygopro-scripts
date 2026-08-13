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
-- 定义过滤函数：判定怪兽是否为表侧表示且为调整怪兽。
function c50621530.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 计算攻击力上升数值：统计场上表侧表示存在的调整怪兽数量，再乘以500。
function c50621530.atkval(e,c)
	-- 返回场上表侧表示调整怪兽数量×500的结果，作为此效果的攻击力上升值。
	return Duel.GetMatchingGroupCount(c50621530.cfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)*500
end
