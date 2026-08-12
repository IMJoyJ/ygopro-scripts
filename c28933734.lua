--闇の仮面
-- 效果：
-- ①：这张卡反转的场合，以自己墓地1张陷阱卡为对象发动。那张卡加入手卡。
function c28933734.initial_effect(c)
	-- ①：这张卡反转的场合，以自己墓地1张陷阱卡为对象发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c28933734.target)
	e1:SetOperation(c28933734.operation)
	c:RegisterEffect(e1)
end
-- 过滤墓地中的陷阱卡并可以加入手牌的卡片
function c28933734.filter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 选择对象：从自己墓地选择1张陷阱卡作为效果对象
function c28933734.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28933734.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张墓地陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c28933734.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：将选中的卡加入手牌并确认对方看到
function c28933734.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果选择的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认展示该张卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
