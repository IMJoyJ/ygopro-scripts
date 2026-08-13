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
-- 定义过滤条件：选择表侧表示且卡号为20394040（即「野蛮人1号」）的怪兽卡。
function c40453765.filter(c)
	return c:IsFaceup() and c:IsCode(20394040)
end
-- 定义攻击力提升数值的计算函数：根据符合条件的「野蛮人1号」数量计算出这张卡的攻击力上升值。
function c40453765.value(e,c)
	-- 统计效果持有者控制者场上表侧表示且卡号为20394040（「野蛮人1号」）的怪兽数量，每有1只上升500点攻击力。
	return Duel.GetMatchingGroupCount(c40453765.filter,c:GetControler(),LOCATION_MZONE,0,nil)*500
end
