--メタルシルバー・アーマー
-- 效果：
-- ①：只要装备怪兽在自己场上存在，对方不能把装备怪兽以外的双方的场上·墓地·除外状态的怪兽作为效果的对象。
function c33114323.initial_effect(c)
	-- ①：只要装备怪兽在自己场上存在，对方不能把装备怪兽以外的双方的场上·墓地·除外状态的怪兽作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c33114323.target)
	e1:SetOperation(c33114323.operation)
	c:RegisterEffect(e1)
	-- ①：只要装备怪兽在自己场上存在，对方不能把装备怪兽以外的双方的场上·墓地·除外状态的怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0x34,0x34)
	e2:SetCondition(c33114323.effcon)
	e2:SetTarget(c33114323.efftg)
	-- 设置效果值为aux.tgoval函数，用于过滤不会成为对方效果对象的卡片
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ①：只要装备怪兽在自己场上存在，对方不能把装备怪兽以外的双方的场上·墓地·除外状态的怪兽作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 选择装备怪兽的目标，要求是己方场上的表侧表示怪兽
function c33114323.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足选择装备怪兽的条件，即己方场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个己方场上的表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁操作的信息为装备效果
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果的处理函数，将装备卡装备给选中的怪兽
function c33114323.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断装备卡是否处于有效状态且其装备对象存在且为同一玩家
function c33114323.effcon(e)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	return tc and c:GetControler()==tc:GetControler()
end
-- 判断目标怪兽是否不是装备怪兽，且为怪兽卡，且处于表侧表示或不在除外区
function c33114323.efftg(e,c)
	return c~=e:GetHandler():GetEquipTarget() and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
