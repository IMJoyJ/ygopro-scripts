--聖なる魔術師
-- 效果：
-- ①：这张卡反转的场合，以自己墓地1张魔法卡为对象发动。那张卡加入手卡。
function c31560081.initial_effect(c)
	-- ①：这张卡反转的场合，以自己墓地1张魔法卡为对象发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31560081,0))  --"魔法回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c31560081.target)
	e1:SetOperation(c31560081.operation)
	c:RegisterEffect(e1)
end
-- 定义过滤器：卡片必须满足是魔法卡，且能够加入手卡。
function c31560081.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 发动时的目标处理：确认对象必须是自己墓地的魔法卡且满足过滤器；发动时选择自己墓地的1张魔法卡作为对象，并设置回手牌的操作信息。
function c31560081.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31560081.filter(chkc) end
	if chk==0 then return true end
	-- 弹出选择提示，提示当前玩家选择一张要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张满足过滤器条件的魔法卡作为效果对象。
	local g=Duel.SelectTarget(tp,c31560081.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁的处理信息：效果分类为回手牌，处理对象为已选择的目标，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理时的操作：取得对象卡，若对象仍与该效果关联，则将其加入手牌，并向对方确认。
function c31560081.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁中第一个（也是唯一一个）效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将该对象卡以效果原因送回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认回到手卡的那张卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
