--カボチャの馬車
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己的「灰姑娘」可以直接攻击。
-- ②：只要这张卡在怪兽区域存在，自己场上的「急流山的金宫」不会被效果破坏，不会成为对方的效果的对象。
function c14512825.initial_effect(c)
	-- 将卡号72283691（急流山的金宫）登记为本卡记述的卡名，使相关效果（如金宫的特殊召唤）能检索或对应这张卡。
	aux.AddCodeList(c,72283691)
	-- ①：只要这张卡在怪兽区域存在，自己的「灰姑娘」可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 将e1的效果对象限定为卡号78527720的怪兽（即「灰姑娘」），只有「灰姑娘」能获得直接攻击能力。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,78527720))
	c:RegisterEffect(e1)
	-- 不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c14512825.indtg)
	-- 设置e2的Value为aux.tgoval，这是“不会成为对方的效果的对象”的过滤函数，用于实现该保护效果。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤函数：判定目标卡是否为表侧表示且卡号为72283691（即「急流山的金宫」），满足条件才受到保护。
function c14512825.indtg(e,c)
	return c:IsFaceup() and c:IsCode(72283691)
end
