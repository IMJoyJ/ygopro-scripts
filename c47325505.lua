--化石調査
-- 效果：
-- ①：从卡组把1只6星以下的恐龙族怪兽加入手卡。
function c47325505.initial_effect(c)
	-- ①：从卡组把1只6星以下的恐龙族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c47325505.target)
	e1:SetOperation(c47325505.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查满足等级6以下、恐龙族且可以加入手卡的怪兽
function c47325505.filter(c)
	return c:IsLevelBelow(6) and c:IsRace(RACE_DINOSAUR) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，用于确认是否能发动此效果
function c47325505.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断在自己卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c47325505.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息为将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的实际处理函数，执行检索并加入手牌
function c47325505.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c47325505.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
