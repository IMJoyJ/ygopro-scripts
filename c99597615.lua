--悪魔のくちづけ
-- 效果：
-- ①：装备怪兽的攻击力上升700。
-- ②：这张卡从场上送去墓地时，支付500基本分才能发动。这张卡回到卡组最上面。
function c99597615.initial_effect(c)
	-- ①：装备怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c99597615.target)
	e1:SetOperation(c99597615.operation)
	c:RegisterEffect(e1)
	-- 攻击力上升700
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	-- 装备怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：这张卡从场上送去墓地时，支付500基本分才能发动。这张卡回到卡组最上面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(99597615,0))  --"返回卡组"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c99597615.tdcon)
	e4:SetCost(c99597615.tdcost)
	e4:SetTarget(c99597615.tdtg)
	e4:SetOperation(c99597615.tdop)
	c:RegisterEffect(e4)
end
-- ①的发动时处理：进行合法性检查，选择场上1只表侧表示怪兽作为装备对象，并设置装备效果的操作信息。
function c99597615.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动条件判定：场上是否存在至少1只表侧表示怪兽可以作为装备对象（取对象效果）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示：请玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从场上选择1只表侧表示怪兽作为这张卡的装备对象（取对象）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记本次连锁的操作信息：这张卡将以装备效果装备给对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- ①的效果处理：若这张卡和选择的对象仍然合法且对象表侧表示，则把这张卡装备给那只怪兽。
function c99597615.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备魔法卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- ②的发动条件：这张卡从场上被送去墓地，而不是从手卡或卡组被送去墓地。
function c99597615.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②的发动代价：检查是否满足支付500基本分并实际支付。
function c99597615.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动代价：能否支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500)
	-- 支付500基本分作为发动代价。
	else Duel.PayLPCost(tp,500)	end
end
-- ②的发动时处理：确认这张卡能回到卡组，并登记回卡组操作信息。
function c99597615.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 登记本次连锁将进行回卡组处理，对象为这张卡。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ②的效果处理：若这张卡仍然存在且与其效果相关，将其送回卡组最顶端。
function c99597615.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡因效果送回持有者卡组的最顶端。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
