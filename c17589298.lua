--サクリファイス・ソード
-- 效果：
-- 暗属性怪兽才能装备。装备怪兽的攻击力上升400。装备怪兽被作为祭品让这张卡送去墓地的场合，这张卡回到手卡。
function c17589298.initial_effect(c)
	-- 装备效果，可以装备到暗属性怪兽上
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c17589298.target)
	e1:SetOperation(c17589298.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升400
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(400)
	c:RegisterEffect(e2)
	-- 暗属性怪兽才能装备
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c17589298.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽被作为祭品让这张卡送去墓地的场合，这张卡回到手卡
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetDescription(aux.Stringid(17589298,0))  --"返回手牌"
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c17589298.retcon)
	e4:SetTarget(c17589298.rettg)
	e4:SetOperation(c17589298.retop)
	c:RegisterEffect(e4)
end
-- 限制装备对象必须为暗属性怪兽
function c17589298.eqlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
-- 筛选场上正面表示的暗属性怪兽
function c17589298.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 选择一个场上正面表示的暗属性怪兽作为装备对象
function c17589298.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c17589298.filter(chkc) end
	-- 判断是否存在符合条件的装备对象
	if chk==0 then return Duel.IsExistingTarget(c17589298.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个场上正面表示的暗属性怪兽作为装备对象
	Duel.SelectTarget(tp,c17589298.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示将要进行装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给目标怪兽
function c17589298.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判断装备卡因失去装备对象且装备怪兽被解放而送去墓地
function c17589298.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_RELEASE)
end
-- 设置返回手牌的效果处理信息
function c17589298.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置返回手牌的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 将装备卡送回手牌并确认其存在
function c17589298.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将装备卡以效果原因送回手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方确认装备卡的存在
		Duel.ConfirmCards(1-tp,c)
	end
end
