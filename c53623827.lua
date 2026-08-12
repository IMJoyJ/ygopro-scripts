--トップ・ランナー
-- 效果：
-- 只要这张卡在场上表侧表示存在，自己场上表侧表示存在的全部同调怪兽的攻击力上升600。
function c53623827.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，自己场上表侧表示存在的全部同调怪兽的攻击力上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置效果目标为场上表侧表示存在的同调怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SYNCHRO))
	e1:SetValue(600)
	c:RegisterEffect(e1)
end
