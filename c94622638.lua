--A・ジェネクス・パワーコール
-- 效果：
-- ①：只要这张卡在怪兽区域存在，持有和这张卡相同属性的自己场上的其他怪兽的攻击力上升500。
function c94622638.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，持有和这张卡相同属性的自己场上的其他怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c94622638.atktg)
	e1:SetValue(500)
	c:RegisterEffect(e1)
end
-- 过滤受影响的怪兽，限定为自身以外且与自身属性相同的怪兽
function c94622638.atktg(e,c)
	return c~=e:GetHandler() and e:GetHandler():IsAttribute(c:GetAttribute())
end
