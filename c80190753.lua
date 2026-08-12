--桜姫タレイア
-- 效果：
-- ①：这张卡的攻击力上升自己场上的植物族怪兽数量×100。
-- ②：只要这张卡在怪兽区域存在，这张卡以外的场上的植物族怪兽不会被效果破坏。
function c80190753.initial_effect(c)
	-- ①：这张卡的攻击力上升自己场上的植物族怪兽数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c80190753.val)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，这张卡以外的场上的植物族怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c80190753.target)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤表侧表示的植物族怪兽
function c80190753.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 计算攻击力上升值的回调函数，返回自己场上表侧表示植物族怪兽数量×100
function c80190753.val(e,c)
	-- 获取自己场上表侧表示的植物族怪兽数量并乘以100
	return Duel.GetMatchingGroupCount(c80190753.filter,c:GetControler(),LOCATION_MZONE,0,nil)*100
end
-- 过滤这张卡以外的场上的植物族怪兽作为效果适用对象
function c80190753.target(e,c)
	return c~=e:GetHandler() and c:IsRace(RACE_PLANT)
end
