--カボチャの馬車
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己的「灰姑娘」可以直接攻击。
-- ②：只要这张卡在怪兽区域存在，自己场上的「急流山的金宫」不会被效果破坏，不会成为对方的效果的对象。
function c14512825.initial_effect(c)
	-- 为卡片注册「急流山的金宫」的卡片代码，用于后续效果判断
	aux.AddCodeList(c,72283691)
	-- 只要这张卡在怪兽区域存在，自己的「灰姑娘」可以直接攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为卡号为「灰姑娘」（78527720）的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,78527720))
	c:RegisterEffect(e1)
	-- 只要这张卡在怪兽区域存在，自己场上的「急流山的金宫」不会被效果破坏，不会成为对方的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c14512825.indtg)
	-- 设置效果值为过滤函数，使目标不会成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 定义用于判断目标是否为表侧表示的「急流山的金宫」的函数
function c14512825.indtg(e,c)
	return c:IsFaceup() and c:IsCode(72283691)
end
