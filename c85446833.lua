--ゼロゼロック
-- 效果：
-- 只要这张卡在场上存在，对方不能选择表侧攻击表示存在的攻击力0的怪兽作为攻击对象。
function c85446833.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，对方不能选择表侧攻击表示存在的攻击力0的怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c85446833.target)
	c:RegisterEffect(e2)
end
-- 判断目标怪兽是否为表侧攻击表示且攻击力为0，以此确定其是否不能被选择为攻击对象。
function c85446833.target(e,c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAttack(0)
end
