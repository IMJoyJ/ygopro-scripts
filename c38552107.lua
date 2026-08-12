--光の角
-- 效果：
-- 装备怪兽的守备力上升800。这张卡从场地送入墓地时，若支付500基本分则回到卡组最上面。
function c38552107.initial_effect(c)
	-- 装备怪兽的守备力上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c38552107.target)
	e1:SetOperation(c38552107.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场地送入墓地时，若支付500基本分则回到卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 装备怪兽的守备力上升800。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这张卡从场地送入墓地时，若支付500基本分则回到卡组最上面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38552107,0))  --"返回卡组"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c38552107.tdcon)
	e4:SetCost(c38552107.tdcost)
	e4:SetTarget(c38552107.tdtg)
	e4:SetOperation(c38552107.tdop)
	c:RegisterEffect(e4)
end
-- 用于判断目标怪兽是否为表侧表示状态。
function c38552107.filter(c)
	return c:IsFaceup()
end
-- 选择装备对象，要求目标为场上表侧表示的怪兽。
function c38552107.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c38552107.filter(chkc) end
	-- 检查是否有满足条件的装备目标。
	if chk==0 then return Duel.IsExistingTarget(c38552107.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个场上表侧表示的怪兽作为装备对象。
	Duel.SelectTarget(tp,c38552107.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示将装备卡装备给目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给选定的怪兽。
function c38552107.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断此卡是否从场上送去墓地。
function c38552107.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 支付500基本分作为发动条件。
function c38552107.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分。
	Duel.PayLPCost(tp,500)
end
-- 设置将此卡送回卡组的处理信息。
function c38552107.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置将此卡送回卡组的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 执行将此卡送回卡组的操作。
function c38552107.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡送回卡组最上面。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
