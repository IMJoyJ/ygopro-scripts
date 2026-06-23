--騎士デイ・グレファー
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●自己结束阶段，以自己墓地1张装备魔法卡为对象才能发动。那张卡加入手卡。这个卡名的这个效果1回合只能使用1次。
function c15767889.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- 自己结束阶段，以自己墓地1张装备魔法卡为对象才能发动。那张卡加入手卡。这个卡名的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15767889,0))  --"回收装备魔法"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,15767889)
	e1:SetCondition(c15767889.thcon)
	e1:SetTarget(c15767889.thtg)
	e1:SetOperation(c15767889.thop)
	c:RegisterEffect(e1)
end
-- 判断效果是否可以发动，条件为该卡处于二重状态且为当前回合玩家
function c15767889.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 该卡处于二重状态且为当前回合玩家
	return e:GetHandler():IsDualState() and Duel.GetTurnPlayer()==tp
end
-- 过滤函数，用于筛选墓地中的装备魔法卡
function c15767889.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 设置效果的目标选择逻辑，检查是否有符合条件的墓地装备魔法卡，并选择目标
function c15767889.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c15767889.filter(chkc) end
	-- 检查是否有符合条件的墓地装备魔法卡
	if chk==0 then return Duel.IsExistingTarget(c15767889.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息，提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择符合条件的墓地装备魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c15767889.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，指定将卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果发动时的处理函数，将选中的卡送入手牌并确认对方查看
function c15767889.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认查看该卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
