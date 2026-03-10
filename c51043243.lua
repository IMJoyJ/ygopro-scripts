--ワーム・カルタロス
-- 效果：
-- 反转：从自己卡组把1只4星以下的名字带有「异虫」的爬虫类族怪兽加入手卡。
function c51043243.initial_effect(c)
	-- 反转：从自己卡组把1只4星以下的名字带有「异虫」的爬虫类族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FLIP+EFFECT_TYPE_SINGLE)
	e1:SetTarget(c51043243.tg)
	e1:SetOperation(c51043243.op)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的怪兽：等级4以下、卡名含「异虫」、种族为爬虫类且可以送去手卡
function c51043243.filter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:IsAbleToHand()
end
-- 设置效果处理时的连锁操作信息，指定将要从卡组检索1张卡加入手牌
function c51043243.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息为CATEGORY_TOHAND（回手牌）和CATEGORY_SEARCH（检索），目标为对方玩家卡组中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时执行的操作：提示选择并检索满足条件的怪兽加入手牌，并确认对方查看该卡
function c51043243.op(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家卡组中选择1张满足filter条件的卡
	local g=Duel.SelectMatchingCard(tp,c51043243.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家查看被送去手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
