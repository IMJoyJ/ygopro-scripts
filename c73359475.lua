--聖騎士パーシヴァル
-- 效果：
-- ①：只要这张卡有「圣剑」装备魔法卡装备，这张卡等级上升1星并变成暗属性。
-- ②：有「圣剑」装备魔法卡装备的这张卡被送去墓地的场合，以自己墓地1张「圣剑」卡为对象发动。那张卡加入手卡。
function c73359475.initial_effect(c)
	-- ①：只要这张卡有「圣剑」装备魔法卡装备，这张卡等级上升1星并变成暗属性。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c73359475.eqcon2)
	e2:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_LEVEL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：有「圣剑」装备魔法卡装备的这张卡被送去墓地的场合，以自己墓地1张「圣剑」卡为对象发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(73359475,0))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c73359475.thcon)
	e4:SetTarget(c73359475.thtg)
	e4:SetOperation(c73359475.thop)
	c:RegisterEffect(e4)
end
-- 判断自身是否有「圣剑」装备魔法卡装备
function c73359475.eqcon2(e)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 判断是否满足“有「圣剑」装备魔法卡装备的这张卡被送去墓地”的发动条件
function c73359475.thcon(e,tp,eg,ep,ev,re,r,rp)
	return c73359475.eqcon2(e) and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 过滤自己墓地中可以加入手牌的「圣剑」卡
function c73359475.thfilter(c)
	return c:IsSetCard(0x207a) and c:IsAbleToHand()
end
-- 效果②的对象选择与发动准备，确认墓地有符合条件的卡并选择1张作为对象，设置操作信息
function c73359475.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c73359475.thfilter(chkc) end
	-- 在发动阶段，检查自己墓地是否存在至少1张可以加入手牌的「圣剑」卡
	if chk==0 then return Duel.IsExistingTarget(c73359475.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己墓地中的1张「圣剑」卡作为效果对象
	local g=Duel.SelectTarget(tp,c73359475.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为：将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理，获取对象卡并将其加入手牌
function c73359475.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
