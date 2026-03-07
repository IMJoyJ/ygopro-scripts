--D・マグネンU
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：对方场上有表侧表示的怪兽存在的场合，这张卡只能选择攻击力最高的怪兽作为攻击对象。
-- ●守备表示：只要这张卡在场上表侧表示存在，对方不能选择其他怪兽作为攻击对象。
function c29947751.initial_effect(c)
	-- 效果原文内容：●攻击表示：对方场上有表侧表示的怪兽存在的场合，这张卡只能选择攻击力最高的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetCondition(c29947751.cona)
	e1:SetValue(c29947751.vala)
	c:RegisterEffect(e1)
	-- 效果原文内容：●攻击表示：对方场上有表侧表示的怪兽存在的场合，这张卡只能选择攻击力最高的怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetCondition(c29947751.cona)
	c:RegisterEffect(e2)
	-- 效果原文内容：●守备表示：只要这张卡在场上表侧表示存在，对方不能选择其他怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetCondition(c29947751.cond)
	e3:SetValue(c29947751.atlimit)
	c:RegisterEffect(e3)
end
-- 规则层面作用：判断当前卡是否处于攻击表示且对方场上存在表侧表示的怪兽
function c29947751.cona(e)
	return e:GetHandler():IsAttackPos()
		-- 规则层面作用：检查对方场上是否存在至少1张表侧表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandler():GetControler(),0,LOCATION_MZONE,1,nil)
end
-- 规则层面作用：用于筛选攻击力高于指定值的表侧表示怪兽
function c29947751.filter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end
-- 规则层面作用：当目标怪兽为表侧表示时，检查对方场上是否存在攻击力更高的怪兽
function c29947751.vala(e,c)
	if c:IsFaceup() then
		-- 规则层面作用：检索对方场上是否存在攻击力大于指定值的表侧表示怪兽
		return Duel.IsExistingMatchingCard(c29947751.filter,c:GetControler(),LOCATION_MZONE,0,1,c,c:GetAttack())
	else return true end
end
-- 规则层面作用：判断当前卡是否处于守备表示
function c29947751.cond(e)
	return e:GetHandler():IsDefensePos()
end
-- 规则层面作用：限制攻击目标不能为自身
function c29947751.atlimit(e,c)
	return c~=e:GetHandler()
end
