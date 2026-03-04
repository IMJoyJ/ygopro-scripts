--スクラップ・エリア
-- 效果：
-- ①：从卡组把1只「废铁」调整加入手卡。
function c1050684.initial_effect(c)
	-- ①：从卡组把1只「废铁」调整加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1050684.target)
	e1:SetOperation(c1050684.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的卡片
function c1050684.filter(c)
	return c:IsSetCard(0x24) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- 效果的target函数，用于判断效果是否可以发动
function c1050684.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的卡组中是否存在至少1张满足filter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1050684.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示将要从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的activate函数，用于执行效果的处理流程
function c1050684.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 让玩家选择满足filter条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c1050684.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认选中的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
