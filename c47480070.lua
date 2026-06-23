--アマゾネスの聖戦士
-- 效果：
-- 自己场上每存在1张名称中含有「亚马逊」的怪兽卡，这张卡的攻击力上升100点。
function c47480070.initial_effect(c)
	-- 自己场上每存在1张名称中含有「亚马逊」的怪兽卡，这张卡的攻击力上升100点。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c47480070.val)
	c:RegisterEffect(e1)
end
-- 计算满足条件的怪兽数量并乘以100作为攻击力加成
function c47480070.val(e,c)
	-- 检索满足过滤条件的怪兽数量，并乘以100作为攻击力提升值
	return Duel.GetMatchingGroupCount(c47480070.filter,c:GetControler(),LOCATION_MZONE,0,nil)*100
end
-- 过滤条件：怪兽必须是表侧表示且卡名含有「亚马逊」
function c47480070.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4)
end
