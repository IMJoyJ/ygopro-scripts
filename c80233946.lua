--ゴラ・タートル
-- 效果：
-- 只要这张卡在场上表侧表示存在，攻击力1900以上的怪兽不能进行攻击宣言。
function c80233946.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，攻击力1900以上的怪兽不能进行攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c80233946.atktarget)
	c:RegisterEffect(e1)
end
-- 过滤出场上攻击力在1900以上的怪兽作为限制攻击宣言的对象
function c80233946.atktarget(e,c)
	return c:IsAttackAbove(1900)
end
