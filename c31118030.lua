--占術姫アローシルフ
-- 效果：
-- ①：这张卡反转的场合才能发动。从自己的卡组·墓地选1张仪式魔法卡加入手卡。
function c31118030.initial_effect(c)
	-- 效果原文内容：①：这张卡反转的场合才能发动。从自己的卡组·墓地选1张仪式魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c31118030.thtg)
	e1:SetOperation(c31118030.thop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：定义过滤函数，用于筛选满足条件的仪式魔法卡（类型为魔法卡且可以送去手卡）
function c31118030.thfilter(c)
	return bit.band(c:GetType(),0x82)==0x82 and c:IsAbleToHand()
end
-- 规则层面作用：设置效果的发动条件和处理目标，检查是否满足发动条件并设置操作信息
function c31118030.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查在卡组和墓地中是否存在至少1张满足条件的仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c31118030.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 规则层面作用：设置连锁操作信息，表示将要处理的卡是来自卡组和墓地的1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 规则层面作用：定义效果的处理流程，包括提示选择、选择卡片、将卡片送入手卡并确认
function c31118030.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：向玩家发送提示信息，提示其选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面作用：从卡组和墓地中选择满足条件的1张仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31118030.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的卡片以效果原因送入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面作用：向对方确认所选卡片的卡面信息
		Duel.ConfirmCards(1-tp,g)
	end
end
