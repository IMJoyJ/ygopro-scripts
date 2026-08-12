--セイクリッド・アンタレス
-- 效果：
-- 这张卡召唤·特殊召唤成功时，可以选择自己墓地1只名字带有「星圣」的怪兽加入手卡。
function c42391240.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，可以选择自己墓地1只名字带有「星圣」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42391240,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c42391240.thtg)
	e1:SetOperation(c42391240.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	c42391240.star_knight_summon_effect=e1
end
-- 过滤满足条件的墓地怪兽：名字带有「星圣」且为怪兽卡且可以加入手牌
function c42391240.tgfilter(c)
	return c:IsSetCard(0x53) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果的目标为满足条件的墓地怪兽
function c42391240.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc,exc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c42391240.tgfilter(chkc) end
	-- 检查是否满足选择目标的条件：墓地存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c42391240.tgfilter,tp,LOCATION_GRAVE,0,1,exc) end
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c42391240.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理时的操作信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：将选中的怪兽加入手牌并确认对方看到
function c42391240.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认看到被送入手牌的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
