--草薙剣
-- 效果：
-- 灵魂怪兽才能装备。装备怪兽攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。装备怪兽从自己场上回到手卡让这张卡被送去墓地时，这张卡回到手卡。
function c48716139.initial_effect(c)
	-- 装备怪兽攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c48716139.target)
	e1:SetOperation(c48716139.operation)
	c:RegisterEffect(e1)
	-- 灵魂怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- 装备怪兽从自己场上回到手卡让这张卡被送去墓地时，这张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c48716139.eqlimit)
	c:RegisterEffect(e3)
	-- 返回手牌
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
-- 限制只能装备到灵魂怪兽上
function c48716139.eqlimit(e,c)
	return c:IsType(TYPE_SPIRIT)
end
-- 筛选场上正面表示的灵魂怪兽
function c48716139.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPIRIT)
end
-- 选择一个场上正面表示的灵魂怪兽作为装备对象
function c48716139.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c48716139.filter(chkc) end
	-- 判断是否有符合条件的装备对象
	if chk==0 then return Duel.IsExistingTarget(c48716139.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标
	Duel.SelectTarget(tp,c48716139.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 将装备卡装备给选中的怪兽
function c48716139.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备目标
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作
		Duel.Equip(tp,c,tc)
	end
end
-- 判断是否因失去装备对象而送去墓地且装备对象在手牌中
function c48716139.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_HAND) and ec:IsPreviousControler(tp)
end
-- 设置返回手牌的效果处理信息
function c48716139.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置返回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 将装备卡送回手牌并确认
function c48716139.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片送回手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方确认送回手牌的卡片
		Duel.ConfirmCards(1-tp,c)
	end
end
