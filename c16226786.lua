--深淵の暗殺者
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只怪兽为对象发动。那只对方怪兽破坏。
-- ②：这张卡从手卡送去墓地的场合，以「深渊的暗杀者」以外的自己墓地1只反转怪兽为对象发动。那只怪兽加入手卡。
function c16226786.initial_effect(c)
	-- 效果原文：①：这张卡反转的场合，以对方场上1只怪兽为对象发动。那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16226786,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c16226786.target)
	e1:SetOperation(c16226786.operation)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡从手卡送去墓地的场合，以「深渊的暗杀者」以外的自己墓地1只反转怪兽为对象发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16226786,1))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c16226786.thcon)
	e2:SetTarget(c16226786.thtg)
	e2:SetOperation(c16226786.thop)
	c:RegisterEffect(e2)
end
-- 选择对方场上1只怪兽作为破坏对象
function c16226786.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的对方场上怪兽
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果
function c16226786.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 将对象怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断此卡是否从手卡送去墓地
function c16226786.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 过滤墓地中的反转怪兽（排除自身）
function c16226786.thfilter(c)
	return c:IsType(TYPE_FLIP) and c:IsAbleToHand() and not c:IsCode(16226786)
end
-- 选择墓地中的反转怪兽作为加入手牌的对象
function c16226786.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c16226786.thfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地反转怪兽
	local g=Duel.SelectTarget(tp,c16226786.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息为回手牌效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 执行回手牌效果
function c16226786.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的回手牌对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
