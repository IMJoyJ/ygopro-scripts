--草薙剣
-- 效果：
-- 灵魂怪兽才能装备。装备怪兽攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。装备怪兽从自己场上回到手卡让这张卡被送去墓地时，这张卡回到手卡。
function c48716139.initial_effect(c)
	-- 灵魂怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c48716139.target)
	e1:SetOperation(c48716139.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- 灵魂怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c48716139.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽从自己场上回到手卡让这张卡被送去墓地时，这张卡回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetDescription(aux.Stringid(48716139,0))  --"返回手牌"
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c48716139.retcon)
	e4:SetTarget(c48716139.rettg)
	e4:SetOperation(c48716139.retop)
	c:RegisterEffect(e4)
end
c48716139.has_text_type=TYPE_SPIRIT
-- 判定装备对象必须是灵魂怪兽，用于装备限制。
function c48716139.eqlimit(e,c)
	return c:IsType(TYPE_SPIRIT)
end
-- 过滤条件：选择场上表侧表示的灵魂怪兽作为可能装备对象。
function c48716139.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPIRIT)
end
-- 发动时的取对象处理：选择场上1只表侧表示的灵魂怪兽作为装备对象，并登记为效果对象。
function c48716139.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c48716139.filter(chkc) end
	-- 检查场上是否存在至少1只表侧表示的灵魂怪兽可选，若不存在则无法发动。
	if chk==0 then return Duel.IsExistingTarget(c48716139.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“请选择要装备的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从场上选择1只表侧表示的灵魂怪兽作为装备对象，并将该卡登记为当前连锁的对象。
	Duel.SelectTarget(tp,c48716139.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时，若这张卡和目标仍与效果关联且目标表侧表示，则将这张卡装备给目标怪兽。
function c48716139.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备到目标怪兽上。
		Duel.Equip(tp,c,tc)
	end
end
-- 判定条件：这张卡因失去装备对象被送去墓地，且之前的装备对象位于手牌且之前控制者为这张卡的控制者。
function c48716139.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_HAND) and ec:IsPreviousControler(tp)
end
-- 回手效果发动时无需选择额外对象，总是允许发动，并设置操作信息。
function c48716139.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息：将这张卡加入手牌，用于时点判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡仍与效果关联，则将其返回持有者手牌，并向对方确认。
function c48716139.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张装备卡返回持有者手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 让对手确认返回手牌的这张卡，以公开信息。
		Duel.ConfirmCards(1-tp,c)
	end
end
