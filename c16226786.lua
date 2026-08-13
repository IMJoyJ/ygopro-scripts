--深淵の暗殺者
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只怪兽为对象发动。那只对方怪兽破坏。
-- ②：这张卡从手卡送去墓地的场合，以「深渊的暗杀者」以外的自己墓地1只反转怪兽为对象发动。那只怪兽加入手卡。
function c16226786.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1只怪兽为对象发动。那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16226786,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c16226786.target)
	e1:SetOperation(c16226786.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡送去墓地的场合，以「深渊的暗杀者」以外的自己墓地1只反转怪兽为对象发动。那只怪兽加入手卡。
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
-- ①效果的取对象处理：确认对象必须存在于对方怪兽区且由对方控制，选择对方场上1只怪兽作为对象，并设置破坏该对象的操作信息。
function c16226786.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 向玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为本次效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将破坏类别和所选对象写入操作信息，供效果处理及时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果处理阶段：取得对象并确认其仍与效果关联且仍由对方控制后，将其破坏。
function c16226786.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取出效果处理时记录的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 以效果原因将对象怪兽破坏送去墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡从手卡被送去墓地。
function c16226786.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- ②效果的筛选条件：选择自己墓地中「深渊的暗杀者」以外的反转怪兽，且该怪兽可以被加入手卡。
function c16226786.thfilter(c)
	return c:IsType(TYPE_FLIP) and c:IsAbleToHand() and not c:IsCode(16226786)
end
-- ②效果的取对象处理：选择自己墓地1只符合条件的反转怪兽作为对象，并设置加入手卡的操作信息。
function c16226786.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c16226786.thfilter(chkc) end
	if chk==0 then return true end
	-- 向玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的反转怪兽作为本次效果的对象。
	local g=Duel.SelectTarget(tp,c16226786.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将回手牌类别和所选对象写入操作信息，供效果处理及时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ②效果处理阶段：取得对象并确认其仍与效果关联后，将其加入手卡。
function c16226786.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出效果处理时记录的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
