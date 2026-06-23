--デコイロイド
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，对方不能选择「诱饵机人」以外的表侧表示怪兽作为攻击对象。
function c25034083.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，对方不能选择「诱饵机人」以外的表侧表示怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(c25034083.atlimit)
	c:RegisterEffect(e1)
end
-- 限制对方怪兽选择攻击目标，只有卡号为25034083的表侧表示怪兽可以被选择为攻击对象
function c25034083.atlimit(e,c)
	return not c:IsCode(25034083) and c:IsFaceup()
end
