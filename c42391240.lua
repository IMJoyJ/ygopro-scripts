--セイクリッド・アンタレス
-- 效果：
-- 这张卡召唤·特殊召唤成功时，可以选择自己墓地1只名字带有「星圣」的怪兽加入手卡。
function c42391240.initial_effect(c)
	-- 对应效果原文：『这张卡召唤·特殊召唤成功时，可以选择自己墓地1只名字带有「星圣」的怪兽加入手卡。』 本段代码创建并注册了召唤成功时的诱发选发效果，并实现了选择墓地「星圣」怪兽加入手卡的目标判定与处理逻辑。
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
-- 定义选择墓地星圣怪兽的过滤条件：必须是名字带有「星圣」的怪兽卡，且不存在不能加入手卡的限制（即可加入手卡）。
function c42391240.tgfilter(c)
	return c:IsSetCard(0x53) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与合法性判定函数：检查自己墓地是否存在符合条件的星圣怪兽，若有则提示玩家选择1张作为对象，并设置操作信息为回手牌。
function c42391240.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc,exc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c42391240.tgfilter(chkc) end
	-- 效果发动的合法性检查阶段（chk==0），确认自己墓地存在至少1张满足tgfilter条件的星圣怪兽，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(c42391240.tgfilter,tp,LOCATION_GRAVE,0,1,exc) end
	-- 向玩家tp显示选择提示，提示文字为“请选择要加入手牌的卡”，用于后续选择卡牌时给玩家明确指示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己墓地选择1张满足tgfilter条件的星圣怪兽作为效果对象，并自动与当前效果建立关联。
	local g=Duel.SelectTarget(tp,c42391240.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次效果处理的操作信息：将选择的卡加入手牌，数量为1，供后续处理及连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：取出选择的目标卡，若该卡仍与效果关联，则将其加入手牌并向对方玩家展示确认。
function c42391240.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这个效果发动时选择的第一张（也是唯一一张）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果为原因，将目标卡送入（返回）其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手牌的这张卡展示给对方玩家（1-tp）确认，使对方知晓加入手牌的是哪张卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
