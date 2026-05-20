--地縛大神官
-- 效果：
-- ①：只要这张卡在怪兽区域存在，「地缚神」怪兽不会被自身的效果破坏。
function c67987302.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，「地缚神」怪兽不会被自身的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果影响的目标为「地缚神」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1021))
	e1:SetValue(c67987302.efilter)
	c:RegisterEffect(e1)
end
-- 定义破坏过滤条件，判定导致破坏的效果的持有者是否是该怪兽自身
function c67987302.efilter(e,re,rp,c)
	return re:GetOwner()==c
end
