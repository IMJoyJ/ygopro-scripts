--氷結界の守護陣
-- 效果：
-- ①：只要自己场上有其他的「冰结界」怪兽存在，持有这张卡的守备力以上的攻击力的对方怪兽不能攻击宣言。
function c82498947.initial_effect(c)
	-- ①：只要自己场上有其他的「冰结界」怪兽存在，持有这张卡的守备力以上的攻击力的对方怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(c82498947.tg)
	e1:SetCondition(c82498947.con)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「冰结界」怪兽
function c82498947.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 效果适用条件：自己场上存在自身以外的「冰结界」怪兽
function c82498947.con(e)
	-- 检查自己场上是否存在至少1张除这张卡以外的表侧表示「冰结界」怪兽
	return Duel.IsExistingMatchingCard(c82498947.filter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤受影响的怪兽：攻击力在自身守备力以上的怪兽
function c82498947.tg(e,c)
	return c:GetAttack()>=e:GetHandler():GetDefense()
end
