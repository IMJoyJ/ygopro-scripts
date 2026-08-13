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
-- 定义检索筛选条件：4星以下、卡名含「异虫」字段、爬虫类族且能被加入手卡的怪兽。
function c51043243.filter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:IsAbleToHand()
end
-- 反转效果的发动判定：chk==0时允许发动，并设置本次操作涉及从卡组检索加入手牌的类别信息。
function c51043243.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将本次效果标记为加入手卡类别，并声明从tp卡组将1张卡加入手卡（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：提示玩家选择符合条件的卡，从卡组检索1只「异虫」爬虫类怪兽，若选到则将其加入手卡并向对方展示。
function c51043243.op(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选出1张满足filter检索条件的卡。
	local g=Duel.SelectMatchingCard(tp,c51043243.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
