--聖なる魔術師
-- 效果：
-- ①：这张卡反转的场合，以自己墓地1张魔法卡为对象发动。那张卡加入手卡。
function c31560081.initial_effect(c)
	-- 效果原文内容：①：这张卡反转的场合，以自己墓地1张魔法卡为对象发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31560081,0))  --"魔法回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c31560081.target)
	e1:SetOperation(c31560081.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的魔法卡（在墓地且能加入手卡）
function c31560081.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置效果目标为己方墓地的魔法卡
function c31560081.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31560081.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张己方墓地的魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c31560081.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：将选中的卡加入手牌并确认对方看到
function c31560081.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认目标卡的卡面信息
		Duel.ConfirmCards(1-tp,tc)
	end
end
