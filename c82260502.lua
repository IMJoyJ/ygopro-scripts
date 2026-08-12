--ヒエラコスフィンクス
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，对方不能选择里侧守备表示的怪兽作为攻击对象。
function c82260502.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，对方不能选择里侧守备表示的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c82260502.atlimit)
	c:RegisterEffect(e1)
end
-- 判断目标怪兽是否为里侧守备表示
function c82260502.atlimit(e,c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE)
end
