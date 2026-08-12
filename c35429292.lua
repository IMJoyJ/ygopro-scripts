--ピクシーナイト
-- 效果：
-- 这张卡被战斗破坏送去墓地时，由对方选择自己墓地里的1张魔法卡，放在自己卡组的最上面。
function c35429292.initial_effect(c)
	-- 诱发必发效果，对应一速的【……发动】
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
-- 这张卡被战斗破坏送去墓地时
function c35429292.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 选择满足条件的魔法卡
function c35429292.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 选择对方墓地里的一张魔法卡
function c35429292.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35429292.filter(chkc) end
	if chk==0 then return true end
	-- 向对方提示“请选择要返回卡组的卡”
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方墓地里的一张魔法卡作为目标
	local g=Duel.SelectTarget(1-tp,c35429292.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理时要将目标卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 将选中的魔法卡送回对方卡组最上面
function c35429292.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送回卡组最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
