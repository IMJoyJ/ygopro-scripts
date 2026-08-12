--増援
-- 效果：
-- ①：从卡组把1只4星以下的战士族怪兽加入手卡。
function c32807846.initial_effect(c)
	-- ①：从卡组把1只4星以下的战士族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32807846.target)
	e1:SetOperation(c32807846.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查卡组中是否存在满足条件的卡片（等级4以下、战士族、可加入手卡）
function c32807846.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 效果的发动时点处理，检查卡组中是否存在满足条件的卡片并设置操作信息
function c32807846.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即卡组中是否存在至少1张满足过滤条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c32807846.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，执行检索并加入手牌的操作
function c32807846.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c32807846.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认翻开的卡牌
		Duel.ConfirmCards(1-tp,g)
	end
end
