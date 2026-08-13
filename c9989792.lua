--トラミッド・フォートレス
-- 效果：
-- 「三形金字塔·大要塞」的③的效果1回合只能使用1次。
-- ①：场上的岩石族怪兽的守备力上升500。
-- ②：场上的「三形金字塔」怪兽不会被效果破坏。
-- ③：场地区域的表侧表示的这张卡被送去墓地的场合，以自己墓地1只「三形金字塔」怪兽为对象才能发动。那只怪兽加入手卡。
function c9989792.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的岩石族怪兽的守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设定该效果仅对场上的岩石族怪兽生效。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ROCK))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- ②：场上的「三形金字塔」怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设定该效果仅对场上的「三形金字塔」系列怪兽生效。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe2))
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 「三形金字塔·大要塞」的③的效果1回合只能使用1次。③：场地区域的表侧表示的这张卡被送去墓地的场合，以自己墓地1只「三形金字塔」怪兽为对象才能发动。那只怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetDescription(aux.Stringid(9989792,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,9989792)
	e4:SetCondition(c9989792.thcon)
	e4:SetTarget(c9989792.thtg)
	e4:SetOperation(c9989792.thop)
	c:RegisterEffect(e4)
end
-- 效果发动的条件：这张卡此前位于场地区域且为表侧表示，从场上被送去墓地。
function c9989792.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_FZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 检索墓地中满足“三形金字塔”怪兽且能够加入手卡的卡牌。
function c9989792.thfilter(c)
	return c:IsSetCard(0xe2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动的目标选择处理：从自己墓地选择1只「三形金字塔」怪兽作为对象。
function c9989792.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c9989792.thfilter(chkc) end
	-- 发动时确认自己墓地是否存在1只符合条件的「三形金字塔」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c9989792.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作者显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 自己从墓地选择1只符合条件的「三形金字塔」怪兽，并将其设置为效果对象。
	local g=Duel.SelectTarget(tp,c9989792.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次操作信息：此次效果处理将把对象卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将先前选择的对象卡加入手牌。
function c9989792.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这次效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因加入持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
