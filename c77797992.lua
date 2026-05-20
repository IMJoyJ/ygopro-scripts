--森の聖獣 アルパカリブ
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：自己场上表侧攻击表示存在的鸟兽族·昆虫族·植物族怪兽不会被战斗破坏。
-- ●守备表示：自己场上表侧守备表示存在的鸟兽族·昆虫族·植物族怪兽不会成为卡的效果的对象，不会被卡的效果破坏。
function c77797992.initial_effect(c)
	-- ●攻击表示：自己场上表侧攻击表示存在的鸟兽族·昆虫族·植物族怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c77797992.cona)
	e1:SetTarget(c77797992.targeta)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ●守备表示：自己场上表侧守备表示存在的鸟兽族·昆虫族·植物族怪兽不会成为卡的效果的对象，不会被卡的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c77797992.cond)
	e2:SetTarget(c77797992.targetd)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 判断此卡自身是否处于攻击表示，作为攻击表示效果的适用条件
function c77797992.cona(e)
	return e:GetHandler():IsAttackPos()
end
-- 过滤出自己场上表侧攻击表示的鸟兽族·昆虫族·植物族怪兽作为效果影响对象
function c77797992.targeta(e,c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsRace(RACE_WINDBEAST+RACE_PLANT+RACE_INSECT)
end
-- 判断此卡自身是否处于守备表示，作为守备表示效果的适用条件
function c77797992.cond(e)
	return e:GetHandler():IsDefensePos()
end
-- 过滤出自己场上表侧守备表示的鸟兽族·昆虫族·植物族怪兽作为效果影响对象
function c77797992.targetd(e,c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsRace(RACE_WINDBEAST+RACE_PLANT+RACE_INSECT)
end
