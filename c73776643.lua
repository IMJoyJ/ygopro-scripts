--オヤコーン
-- 效果：
-- 场地魔法卡表侧表示存在的场合，这张卡的攻击力上升1000。
function c73776643.initial_effect(c)
	-- 场地魔法卡表侧表示存在的场合，这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c73776643.condtion)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
end
-- 定义效果的生效条件，即判断场上是否存在表侧表示的场地魔法卡
function c73776643.condtion(e)
	-- 检查双方的场地区是否存在至少1张表侧表示的卡
	return Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
