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
-- 计算这张卡攻击力的上升数值：统计自己场上表侧表示且名含「亚马逊」的怪兽卡数量，每张提供100点攻击力。
function c47480070.val(e,c)
	-- 返回自己场上满足条件的「亚马逊」怪兽数量乘以100，作为这张卡的攻击力上升值。
	return Duel.GetMatchingGroupCount(c47480070.filter,c:GetControler(),LOCATION_MZONE,0,nil)*100
end
-- 过滤条件：卡片为表侧表示，且属于「亚马逊」系列（SetCard 0x4）。
function c47480070.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4)
end
