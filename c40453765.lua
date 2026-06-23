--バーバリアン2号
-- 效果：
-- ①：自己场上的「野蛮人1号」每有1只，这张卡的攻击力上升500。
function c40453765.initial_effect(c)
	-- ①：自己场上的「野蛮人1号」每有1只，这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c40453765.value)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上表侧表示的「野蛮人1号」
function c40453765.filter(c)
	return c:IsFaceup() and c:IsCode(20394040)
end
-- 计算攻击力上升值，统计己方场上「野蛮人1号」的数量并乘以500
function c40453765.value(e,c)
	-- 检索满足条件的「野蛮人1号」数量并乘以500作为攻击力加成
	return Duel.GetMatchingGroupCount(c40453765.filter,c:GetControler(),LOCATION_MZONE,0,nil)*500
end
