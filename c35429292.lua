--ピクシーナイト
-- 效果：
-- 这张卡被战斗破坏送去墓地时，由对方选择自己墓地里的1张魔法卡，放在自己卡组的最上面。
function c35429292.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，由对方选择自己墓地里的1张魔法卡，放在自己卡组的最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35429292,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c35429292.condition)
	e1:SetTarget(c35429292.target)
	e1:SetOperation(c35429292.operation)
	c:RegisterEffect(e1)
end
-- 效果触发条件：自身被战斗破坏送去墓地后，效果才能发动。
function c35429292.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 选择的卡片必须是魔法卡，并且能够返回卡组。
function c35429292.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 发动时由对方从自己墓地选择1张符合条件的魔法卡作为对象，并设置回卡组的操作信息。
function c35429292.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35429292.filter(chkc) end
	if chk==0 then return true end
	-- 向对方玩家显示选择提示“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 由对方（1-tp）从自己（tp）墓地选择1张满足条件的魔法卡作为效果对象。
	local g=Duel.SelectTarget(1-tp,c35429292.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁的回卡组操作信息，对象为已选择的卡片，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理时，将所选的魔法卡送回持有者卡组顶端。
function c35429292.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时锁定的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回其持有者卡组的最顶端。
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
