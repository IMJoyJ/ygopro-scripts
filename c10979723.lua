--アマゾネスペット虎
-- 效果：
-- ①：「亚马逊宠物虎」在自己场上只能有1只表侧表示存在。
-- ②：这张卡的攻击力上升自己场上的「亚马逊」怪兽数量×400。
-- ③：只要这张卡在怪兽区域存在，对方怪兽不能向这张卡以外的「亚马逊」怪兽攻击。
function c10979723.initial_effect(c)
	c:SetUniqueOnField(1,0,10979723)
	-- 效果②：这张卡的攻击力上升自己场上的「亚马逊」怪兽数量×400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c10979723.val)
	c:RegisterEffect(e1)
	-- 效果③：只要这张卡在怪兽区域存在，对方怪兽不能向这张卡以外的「亚马逊」怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetValue(c10979723.atlimit)
	c:RegisterEffect(e2)
end
-- 计算效果持有者控制者场上表侧表示的「亚马逊」怪兽数量，并乘以400作为攻击力上升值。
function c10979723.val(e,c)
	-- 返回自己场上表侧表示且属于「亚马逊」字段的怪兽数量乘以400的数值。
	return Duel.GetMatchingGroupCount(c10979723.filter,c:GetControler(),LOCATION_MZONE,0,nil)*400
end
-- 过滤条件：卡片是表侧表示，且属于「亚马逊」字段（SetCard 0x4）。
function c10979723.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4)
end
-- 当目标怪兽是表侧表示、属于「亚马逊」字段且不是效果持有者本卡时返回true，使对方不能选择该怪兽作为攻击对象，从而限制对方只能攻击这张卡。
function c10979723.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x4) and c~=e:GetHandler()
end
