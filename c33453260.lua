--コミックハンド
-- 效果：
-- 自己场上有「卡通世界」存在的场合才能给对方场上的怪兽装备。
-- ①：得到装备怪兽的控制权。
-- ②：装备怪兽也当作卡通怪兽使用，对方场上没有卡通怪兽存在的场合，装备怪兽可以直接攻击。
-- ③：场上没有「卡通世界」存在的场合这张卡破坏。
function c33453260.initial_effect(c)
	-- 调用aux.AddCodeList将卡通世界（15259703）登记为此卡记述的卡名，以便进行关联判定。
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
	-- 自己场上有「卡通世界」存在的场合才能给对方场上的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c33453260.eqlimit)
	c:RegisterEffect(e2)
	-- ①：得到装备怪兽的控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetValue(c33453260.cval)
	c:RegisterEffect(e3)
	-- ②：装备怪兽也当作卡通怪兽使用。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_ADD_TYPE)
	e4:SetValue(TYPE_TOON)
	c:RegisterEffect(e4)
	-- 对方场上没有卡通怪兽存在的场合，装备怪兽可以直接攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetCondition(c33453260.dircon)
	c:RegisterEffect(e5)
	-- ③：场上没有「卡通世界」存在的场合这张卡破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SELF_DESTROY)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c33453260.descon)
	c:RegisterEffect(e6)
end
-- 过滤出表侧表示且卡名为卡通世界（15259703）的卡，用于判断场上是否存在卡通世界。
function c33453260.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 效果发动条件：自己场上存在至少1张表侧表示的卡通世界时才可发动。
function c33453260.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在符合条件的卡通世界，存在则返回 true。
	return Duel.IsExistingMatchingCard(c33453260.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤出表侧表示的怪兽，作为装备对象的选择条件。
function c33453260.filter(c)
	return c:IsFaceup()
end
-- 效果发动时的目标选择：选择对方场上1只表侧表示怪兽，并设置装备和控制权的操作信息。
function c33453260.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c33453260.filter(chkc) end
	-- 发动时检查是否有至少1只对方场上的表侧怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c33453260.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示文字「请选择要装备的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从对方场上选择1只表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c33453260.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果将把此卡装备给对象（CATEGORY_EQUIP）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置操作信息：本次效果会改变对象怪兽的控制权（CATEGORY_CONTROL）。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：若此卡与对象仍然有效且对象表侧，则将此卡装备给对象怪兽。
function c33453260.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理阶段的对象怪兽（即之前选择的目标）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备到对象怪兽上。
		Duel.Equip(tp,c,tc)
	end
end
-- 装备限制：此卡只能装备给自己场上有卡通世界且控制者为对方的怪兽；若已装备该怪兽则维持装备状态。
function c33453260.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c33453260.condition(e,tp) and tp~=c:GetControler()
		or e:GetHandler():GetEquipTarget()==c
end
-- 控制权变更值：装备怪兽的控制权变为这张卡的控制者。
function c33453260.cval(e,c)
	return e:GetHandlerPlayer()
end
-- 过滤出表侧表示的卡通怪兽，用于判断对方场上是否存在卡通怪兽。
function c33453260.dirfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 直接攻击条件：对方场上没有表侧表示的卡通怪兽时，装备怪兽可以直接攻击。
function c33453260.dircon(e)
	-- 返回对方场上不存在表侧卡通怪兽的判定结果。
	return not Duel.IsExistingMatchingCard(c33453260.dirfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 自我破坏条件：双方场上没有表侧表示的卡通世界时，这张卡自我破坏。
function c33453260.descon(e)
	-- 返回全场不存在卡通世界的判定结果。
	return not Duel.IsExistingMatchingCard(c33453260.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
