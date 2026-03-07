--アクアアクトレス・テトラ
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从卡组把1张「水族馆」卡加入手卡。
function c39260991.initial_effect(c)
	-- 效果原文内容：①：1回合1次，自己主要阶段才能发动。从卡组把1张「水族馆」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c39260991.thtg)
	e1:SetOperation(c39260991.thop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选卡组中满足条件的「水族馆」卡
function c39260991.filter(c)
	return c:IsSetCard(0xce) and c:IsAbleToHand()
end
-- 效果的发动时点处理函数，检查是否满足发动条件并设置操作信息
function c39260991.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以自己为玩家，在卡组中是否存在至少1张满足filter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c39260991.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为检索卡组并加入手牌的效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，执行检索并加入手牌的操作
function c39260991.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足filter条件的卡
	local g=Duel.SelectMatchingCard(tp,c39260991.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认玩家选中的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
