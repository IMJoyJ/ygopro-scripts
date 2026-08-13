--D・マグネンU
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：对方场上有表侧表示的怪兽存在的场合，这张卡只能选择攻击力最高的怪兽作为攻击对象。
-- ●守备表示：只要这张卡在场上表侧表示存在，对方不能选择其他怪兽作为攻击对象。
function c29947751.initial_effect(c)
	-- ●攻击表示：对方场上有表侧表示的怪兽存在的场合，这张卡只能选择攻击力最高的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetCondition(c29947751.cona)
	e1:SetValue(c29947751.vala)
	c:RegisterEffect(e1)
	-- 对方场上有表侧表示的怪兽存在的场合，这张卡只能选择攻击力最高的怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetCondition(c29947751.cona)
	c:RegisterEffect(e2)
	-- ●守备表示：只要这张卡在场上表侧表示存在，对方不能选择其他怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetCondition(c29947751.cond)
	e3:SetValue(c29947751.atlimit)
	c:RegisterEffect(e3)
end
-- 该条件函数用于判定本卡的攻击表示限制是否适用：自身处于攻击表示，且对方场上有表侧表示怪兽存在时返回 true。
function c29947751.cona(e)
	return e:GetHandler():IsAttackPos()
		-- 检查对方场上是否存在至少1只表侧表示怪兽。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandler():GetControler(),0,LOCATION_MZONE,1,nil)
end
-- 过滤函数：判断怪兽是否表侧表示且攻击力大于给定攻击力，用于查找攻击力更高的怪兽。
function c29947751.filter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end
-- 该 Value 函数用于限制攻击对象：若候选对象为表侧怪兽且场上有攻击力高于它的怪兽，或候选对象不是表侧表示，则返回 true 表示不能选择该对象，从而保证只能选择攻击力最高的表侧怪兽为攻击对象。
function c29947751.vala(e,c)
	if c:IsFaceup() then
		-- 检查候选攻击对象控制者的怪兽区是否存在另一只表侧表示且攻击力大于它的怪兽；若存在则返回 true，使该候选对象不可被选择。
		return Duel.IsExistingMatchingCard(c29947751.filter,c:GetControler(),LOCATION_MZONE,0,1,c,c:GetAttack())
	else return true end
end
-- 判断这张卡是否处于守备表示，作为守备表示效果是否适用的条件。
function c29947751.cond(e)
	return e:GetHandler():IsDefensePos()
end
-- 该 Value 函数用于限制对方攻击对象：若候选攻击对象不是本卡自身，则返回 true（不能选择），即对方只能选择本卡为攻击对象。
function c29947751.atlimit(e,c)
	return c~=e:GetHandler()
end
