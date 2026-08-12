--CNo.65 裁断魔王ジャッジ・デビル
-- 效果：
-- 暗属性3星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力下降1000。
-- ②：这张卡有「No.65 裁断魔人」在作为超量素材的场合，得到以下效果。
-- ●只要这张卡在怪兽区域存在，对方场上的怪兽不能把效果发动。
function c49195710.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，要求使用暗属性怪兽作为素材，等级为3，数量为3。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),3,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49195710,0))  --"攻守下降"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c49195710.cost)
	e1:SetTarget(c49195710.target)
	e1:SetOperation(c49195710.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡有「No.65 裁断魔人」在作为超量素材的场合，得到以下效果。●只要这张卡在怪兽区域存在，对方场上的怪兽不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c49195710.accon)
	c:RegisterEffect(e2)
end
-- 设置该卡的XYZ编号为65。
aux.xyz_number[49195710]=65
-- 效果发动时支付1个超量素材作为代价。
function c49195710.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义目标过滤函数，用于筛选表侧表示的怪兽。
function c49195710.filter(c)
	return c:IsFaceup()
end
-- 设置效果的目标选择逻辑，选择对方场上一只表侧表示的怪兽。
function c49195710.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c49195710.filter(chkc) end
	-- 检查是否存在符合条件的目标怪兽。
	if chk==0 then return Duel.IsExistingTarget(c49195710.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择一张表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上选择一只表侧表示的怪兽作为目标。
	Duel.SelectTarget(tp,c49195710.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数，使目标怪兽攻击力和守备力各下降1000。
function c49195710.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 为目标怪兽添加攻击力下降1000的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 判断该卡是否含有编号为3790062（No.65 裁断魔人）的超量素材。
function c49195710.accon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,3790062)
end
