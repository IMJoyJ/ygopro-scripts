--剣闘獣の闘器グラディウス
-- 效果：
-- 名字带有「剑斗兽」的怪兽才能装备。装备怪兽的攻击力上升300。装备怪兽从自己场上回到卡组让这张卡被送去墓地时，这张卡回到手卡。
function c25407406.initial_effect(c)
	-- 名字带有「剑斗兽」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c25407406.target)
	e1:SetOperation(c25407406.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 名字带有「剑斗兽」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c25407406.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽从自己场上回到卡组让这张卡被送去墓地时，这张卡回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetDescription(aux.Stringid(25407406,0))  --"返回手牌"
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c25407406.retcon)
	e4:SetTarget(c25407406.rettg)
	e4:SetOperation(c25407406.retop)
	c:RegisterEffect(e4)
end
-- 判断怪兽是否拥有剑斗兽字段（0x1019），作为装备对象限制条件。
function c25407406.eqlimit(e,c)
	return c:IsSetCard(0x1019)
end
-- 过滤条件：怪兽需表侧表示且名字带有「剑斗兽」。
function c25407406.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019)
end
-- 发动时的目标选择：检查场上是否存在符合条件的剑斗兽怪兽，若存在则选择一只作为装备对象，并设置装备的操作信息。
function c25407406.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c25407406.filter(chkc) end
	-- 发动合法性检测：检查场上是否存在至少1只符合条件的表侧表示剑斗兽怪兽。
	if chk==0 then return Duel.IsExistingTarget(c25407406.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择装备对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从场上的表侧表示剑斗兽怪兽中选择1只作为装备对象（取对象）。
	Duel.SelectTarget(tp,c25407406.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次效果处理的操作信息：将本卡装备给选择的对象。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若本卡和对象仍与效果关联且对象表侧表示，则执行装备。
function c25407406.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果处理中选择的装备对象。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将本卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- 回手效果的触发条件：本卡因失去装备对象被送去墓地，且原装备对象位于卡组或额外卡组（即从自己场上回到卡组）。
function c25407406.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 回手效果的目标判定：检查本卡能否加入手卡，并设置回手操作信息。
function c25407406.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将本卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 回手效果处理：若本卡仍与效果关联，则将其返回手卡并向对方确认。
function c25407406.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将本卡返回持有者手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家展示返回手卡的这张卡。
		Duel.ConfirmCards(1-tp,c)
	end
end
