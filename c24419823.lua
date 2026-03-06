--マインフィールド
-- 效果：
-- ①：表侧表示的这张卡从自己场上离开时，以自己墓地1张场地魔法卡为对象才能发动。那张卡加入手卡。
function c24419823.initial_effect(c)
	-- 效果原文内容：①：表侧表示的这张卡从自己场上离开时，以自己墓地1张场地魔法卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24419823,0))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c24419823.thcon)
	e2:SetTarget(c24419823.thtg)
	e2:SetOperation(c24419823.thop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断该卡离开场上的时候是否为正面表示状态
function c24419823.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- 规则层面作用：定义可用于选择的目标卡片类型为场地魔法卡且可以加入手牌
function c24419823.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 规则层面作用：设置效果的发动条件，检查是否能从自己墓地选择一张场地魔法卡作为对象
function c24419823.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24419823.filter(chkc) end
	-- 规则层面作用：检查是否满足发动条件，即自己墓地是否存在符合条件的场地魔法卡
	if chk==0 then return Duel.IsExistingTarget(c24419823.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 规则层面作用：向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面作用：选择一张符合条件的墓地场地魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c24419823.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 规则层面作用：设置效果处理时的操作信息，确定将要将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 规则层面作用：效果处理函数，将选中的卡加入手牌并确认对方能看到该卡
function c24419823.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中被选择的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标卡片以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 规则层面作用：向对方玩家确认该卡加入手牌
		Duel.ConfirmCards(1-tp,tc)
	end
end
