--デーモンの斧
-- 效果：
-- ①：装备怪兽的攻击力上升1000。
-- ②：这张卡从场上送去墓地时，把自己场上1只怪兽解放才能发动。这张卡回到卡组最上面。
function c40619825.initial_effect(c)
	-- ①：装备怪兽的攻击力上升1000。（装备魔法的发动与装备处理）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c40619825.target)
	e1:SetOperation(c40619825.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升1000。（攻击力上升效果）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- 装备怪兽。（装备对象限制：只能装备给怪兽）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：这张卡从场上送去墓地时，把自己场上1只怪兽解放才能发动。这张卡回到卡组最上面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(40619825,0))  --"回到卡组的最上面"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c40619825.tdcon)
	e4:SetCost(c40619825.tdcost)
	e4:SetTarget(c40619825.tdtg)
	e4:SetOperation(c40619825.tdop)
	c:RegisterEffect(e4)
end
-- 发动时的取对象处理：选择场上1只表侧表示怪兽作为装备对象，并设定装备操作信息。
function c40619825.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动条件确认：场上存在至少1只表侧表示怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示消息“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只场上表侧表示怪兽作为装备对象，并将其登记为本次连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：装备分类，处理对象为这张卡本身，数量1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：取回对象，若这张卡和对象仍与效果关联且对象表侧表示，则将此卡装备给对象怪兽。
function c40619825.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的装备对象（第一张对象卡）。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- ②的发动条件：这张卡从场上送去墓地，即其之前所在位置为场上。
function c40619825.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②的发动代价：解放自己场上1只怪兽；先确认存在可解放怪兽，再选择并解放。
function c40619825.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上存在至少1只可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择自己场上1只怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选择的怪兽解放，作为发动代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- ②的发动目标：确认这张卡可以返回卡组，并设置回卡组的操作信息。
function c40619825.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置本次连锁的操作信息：回卡组分类，处理对象为这张卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ②的效果处理：若这张卡仍与效果关联，则将其返回持有者卡组最上面。
function c40619825.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡返回持有者卡组最顶端（SEQ_DECKTOP）。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
