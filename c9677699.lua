--ガラスの靴
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽的种族是天使族的场合，装备怪兽的攻击力上升1000。天使族以外的场合，装备怪兽不能攻击，攻击力下降1000。
-- ②：装备怪兽被破坏让这张卡被送去墓地的场合，以自己场上1只「灰姑娘」为对象才能发动。那只自己的「灰姑娘」把这张卡装备。
function c9677699.initial_effect(c)
	-- 以场上1只怪兽为对象才能把这张卡发动。那只怪兽把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c9677699.target)
	e1:SetOperation(c9677699.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的种族是天使族的场合，装备怪兽的攻击力上升1000。天使族以外的场合，... 攻击力下降1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c9677699.value)
	c:RegisterEffect(e2)
	-- 天使族以外的场合，装备怪兽不能攻击
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetCondition(c9677699.atcon)
	c:RegisterEffect(e3)
	-- ②：装备怪兽被破坏让这张卡被送去墓地的场合，以自己场上1只「灰姑娘」为对象才能发动。那只自己的「灰姑娘」把这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(9677699,0))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,9677699)
	e4:SetCondition(c9677699.eqcon)
	e4:SetTarget(c9677699.eqtg)
	e4:SetOperation(c9677699.operation)
	c:RegisterEffect(e4)
	-- 装备限制
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 卡片发动时的对象选择与效果处理准备
function c9677699.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动时，检查场上是否存在可以作为装备对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将这张卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 卡片发动时的效果处理：将这张卡装备给选择的目标怪兽
function c9677699.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 根据装备怪兽的种族，计算并返回攻击力增减数值（天使族上升1000，非天使族下降1000）
function c9677699.value(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	if ec:IsRace(RACE_FAIRY) then
		return 1000
	else
		return -1000
	end
end
-- 判断装备怪兽是否不是天使族，作为不能攻击效果的生效条件
function c9677699.atcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and not ec:IsRace(RACE_FAIRY)
end
-- 判断是否因装备怪兽被破坏而导致这张卡失去装备对象并送去墓地
function c9677699.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_DESTROY)
end
-- 过滤自己场上表侧表示的「灰姑娘」
function c9677699.eqfilter(c)
	return c:IsFaceup() and c:IsCode(78527720)
end
-- 效果②发动时的对象选择与效果处理准备
function c9677699.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c9677699.eqfilter(chkc) end
	-- 在发动时，检查自己魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 在发动时，检查自己场上是否存在可以作为装备对象的「灰姑娘」
		and Duel.IsExistingTarget(c9677699.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「灰姑娘」作为装备对象
	Duel.SelectTarget(tp,c9677699.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息：将这张卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置效果处理信息：这张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
