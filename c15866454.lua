--ポルターガイスト
-- 效果：
-- ①：以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡回到持有者手卡。这张卡的发动和效果不会被无效化。
function c15866454.initial_effect(c)
	-- ①：以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡回到持有者手卡。这张卡的发动和效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetTarget(c15866454.target)
	e1:SetOperation(c15866454.activate)
	c:RegisterEffect(e1)
end
-- 定义对象筛选条件：卡片必须是魔法·陷阱卡且能够加入手卡（不处于不能回手牌的限制下）。
function c15866454.filter(c)
	return c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的目标选择处理：确认可行后，从对方场上选择1张符合条件的魔法·陷阱卡作为对象，并登记回手牌的操作信息。
function c15866454.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c15866454.filter(chkc) end
	-- 发动合法性检查：确认对方场上是否存在至少1张可供选择且符合条件的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c15866454.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，让操作者选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 实际选择对方场上1张满足条件的魔法·陷阱卡，并将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c15866454.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 记录连锁处理信息：本连锁将执行‘返回手牌’分类的处理，目标为选中的那张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时的操作：取得效果对象，若对象仍与效果关联，则将其送回持有者手卡。
function c15866454.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个对象卡（即发动时选择的那张卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回其持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
