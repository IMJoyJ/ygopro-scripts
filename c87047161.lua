--マーメイド・シャーク
-- 效果：
-- 这张卡召唤成功时，可以从卡组把1只3～5星的鱼族怪兽加入手卡。
function c87047161.initial_effect(c)
	-- 这张卡召唤成功时，可以从卡组把1只3～5星的鱼族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87047161,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c87047161.target)
	e1:SetOperation(c87047161.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中等级为3、4、5且可以加入手牌的鱼族怪兽
function c87047161.filter(c)
	return c:IsLevel(3,4,5) and c:IsRace(RACE_FISH) and c:IsAbleToHand()
end
-- 效果发动的目标检查与操作信息设置
function c87047161.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c87047161.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行，从卡组选择怪兽加入手牌并确认
function c87047161.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c87047161.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
