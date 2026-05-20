--極氷獣ポーラ・ペンギン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
-- ②：场上的这张卡被战斗·效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
function c79169622.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79169622,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,79169622)
	e1:SetTarget(c79169622.thtg)
	e1:SetOperation(c79169622.thop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79169622,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,79169622)
	e2:SetCondition(c79169622.thcon2)
	e2:SetTarget(c79169622.thtg2)
	e2:SetOperation(c79169622.thop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备与对象选择
function c79169622.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 在发动阶段，检查对方场上是否存在可以回到手牌的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只可以回到手牌的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为：将选中的怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ①效果的处理：将作为对象的怪兽送回持有者手牌
function c79169622.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件：场上的这张卡被战斗或效果破坏
function c79169622.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果的发动准备与对象选择
function c79169622.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 在发动阶段，检查对方场上是否存在可以回到手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张可以回到手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为：将选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理：将作为对象的卡送回持有者手牌
function c79169622.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
