--アマゾネスペット虎
-- 效果：
-- ①：「亚马逊宠物虎」在自己场上只能有1只表侧表示存在。
-- ②：这张卡的攻击力上升自己场上的「亚马逊」怪兽数量×400。
-- ③：只要这张卡在怪兽区域存在，对方怪兽不能向这张卡以外的「亚马逊」怪兽攻击。
function c10979723.initial_effect(c)
	c:SetUniqueOnField(1,0,10979723)
	-- ②：这张卡的攻击力上升自己场上的「亚马逊」怪兽数量×400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c10979723.val)
	c:RegisterEffect(e1)
	-- ③：只要这张卡在怪兽区域存在，对方怪兽不能向这张卡以外的「亚马逊」怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetValue(c10979723.atlimit)
	c:RegisterEffect(e2)
end
-- 效果作用：计算场上「亚马逊」怪兽数量并乘以400作为攻击力加成
function c10979723.val(e,c)
	-- 规则层面操作：检索满足条件的「亚马逊」怪兽数量并乘以400作为攻击力增加值
	return Duel.GetMatchingGroupCount(c10979723.filter,c:GetControler(),LOCATION_MZONE,0,nil)*400
end
-- 效果作用：判断怪兽是否为表侧表示且为「亚马逊」卡
function c10979723.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4)
end
-- 规则层面操作：设置对方怪兽不能攻击非自身且为「亚马逊」的怪兽
function c10979723.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x4) and c~=e:GetHandler()
end
