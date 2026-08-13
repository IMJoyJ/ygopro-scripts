--光の角
-- 效果：
-- 装备怪兽的守备力上升800。这张卡从场地送入墓地时，若支付500基本分则回到卡组最上面。
function c38552107.initial_effect(c)
	-- 装备怪兽的
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c38552107.target)
	e1:SetOperation(c38552107.operation)
	c:RegisterEffect(e1)
	-- 守备力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 装备怪兽的
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
-- 定义装备对象筛选条件：要求怪兽为表侧表示。
function c38552107.filter(c)
	return c:IsFaceup()
end
-- 发动时处理：确认存在表侧表示怪兽作为装备对象，提示玩家选择目标，选择1只表侧表示怪兽，并设置装备类操作信息。
function c38552107.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c38552107.filter(chkc) end
	-- 效果发动的合法性检查：场上是否存在1只表侧表示怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c38552107.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择装备对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从场上选择1只表侧表示怪兽作为这张卡的装备对象，并将其登记为效果对象。
	Duel.SelectTarget(tp,c38552107.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为装备效果，表示这张卡将装备给所选择的对象。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡和目标怪兽仍与效果关联且怪兽为表侧表示，则将这张卡装备给该怪兽。
function c38552107.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将光之角作为装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 效果发动条件：这张卡从场上区域被送入墓地。
function c38552107.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 发动代价处理：检查并支付500基本分。
function c38552107.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查玩家能否支付500基本分作为代价。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分。
	Duel.PayLPCost(tp,500)
end
-- 效果发动时的目标处理：确认这张卡可以被送回卡组，并设置回卡组的操作信息。
function c38552107.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置操作信息为回卡组类别，表示处理时将该卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡仍与效果关联，则将其送回持有者卡组最顶端。
function c38552107.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以效果送回持有者卡组最上方。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
