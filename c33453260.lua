--コミックハンド
-- 效果：
-- 自己场上有「卡通世界」存在的场合才能给对方场上的怪兽装备。
-- ①：得到装备怪兽的控制权。
-- ②：装备怪兽也当作卡通怪兽使用，对方场上没有卡通怪兽存在的场合，装备怪兽可以直接攻击。
-- ③：场上没有「卡通世界」存在的场合这张卡破坏。
function c33453260.initial_effect(c)
	-- 记录此卡与「卡通世界」的关联
	aux.AddCodeList(c,15259703)
	-- 自己场上有「卡通世界」存在的场合才能给对方场上的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCondition(c33453260.condition)
	e1:SetTarget(c33453260.target)
	e1:SetOperation(c33453260.activate)
	c:RegisterEffect(e1)
	-- 装备怪兽也当作卡通怪兽使用，对方场上没有卡通怪兽存在的场合，装备怪兽可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c33453260.eqlimit)
	c:RegisterEffect(e2)
	-- 得到装备怪兽的控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetValue(c33453260.cval)
	c:RegisterEffect(e3)
	-- 装备怪兽也当作卡通怪兽使用，对方场上没有卡通怪兽存在的场合，装备怪兽可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_ADD_TYPE)
	e4:SetValue(TYPE_TOON)
	c:RegisterEffect(e4)
	-- 场上没有「卡通世界」存在的场合这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetCondition(c33453260.dircon)
	c:RegisterEffect(e5)
	-- 自己场上有「卡通世界」存在的场合才能给对方场上的怪兽装备。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SELF_DESTROY)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c33453260.descon)
	c:RegisterEffect(e6)
end
-- 检查场上是否存在「卡通世界」
function c33453260.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 检查场上是否存在「卡通世界」
function c33453260.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「卡通世界」
	return Duel.IsExistingMatchingCard(c33453260.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 筛选场上正面表示的怪兽
function c33453260.filter(c)
	return c:IsFaceup()
end
-- 选择对方场上的怪兽作为装备对象
function c33453260.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c33453260.filter(chkc) end
	-- 选择对方场上的怪兽作为装备对象
	if chk==0 then return Duel.IsExistingTarget(c33453260.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上的怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c33453260.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置控制权变更的处理信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 执行装备操作
function c33453260.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 设置装备对象限制条件
function c33453260.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c33453260.condition(e,tp) and tp~=c:GetControler()
		or e:GetHandler():GetEquipTarget()==c
end
-- 设置装备怪兽的控制权
function c33453260.cval(e,c)
	return e:GetHandlerPlayer()
end
-- 筛选场上正面表示的卡通怪兽
function c33453260.dirfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 判断对方场上是否没有卡通怪兽
function c33453260.dircon(e)
	-- 判断对方场上是否没有卡通怪兽
	return not Duel.IsExistingMatchingCard(c33453260.dirfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 判断场上是否存在「卡通世界」
function c33453260.descon(e)
	-- 判断场上是否存在「卡通世界」
	return not Duel.IsExistingMatchingCard(c33453260.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
