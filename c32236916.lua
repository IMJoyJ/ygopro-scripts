--虹の橋 ビフレスト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把包含光属性同调怪兽的3只10星以上的怪兽从额外卡组除外才能发动。从卡组把1张场地魔法卡加入手卡。
local s,id,o=GetID()
-- 注册卡片发动时的效果：注册誓约次数限制、发动代价、发动目标和效果处理。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把包含光属性同调怪兽的3只10星以上的怪兽从额外卡组除外才能发动。从卡组把1张场地魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：10星以上且可以作为代价除外的额外怪兽。
function s.rmfilter(c)
	return c:IsLevelAbove(10) and c:IsAbleToRemoveAsCost()
end
-- 过滤条件：光属性的同调怪兽。
function s.cfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 检查条件：卡组中是否存在至少一张光属性同调怪兽。
function s.gcheck(g)
	return g:IsExists(s.cfilter,1,nil)
end
-- 发动代价：从额外卡组把包含光属性同调怪兽的3只10星以上的怪兽除外。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方额外卡组中所有符合除外条件的10星以上怪兽。
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return g:CheckSubGroup(s.gcheck,3,3) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3)
	-- 将选定的卡片正面表示除外作为发动代价。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 过滤条件：可以加入手牌的场地魔法卡。
function s.thfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 效果发动：检查卡组中是否存在可以加入手牌的场地魔法卡，并设置加入手牌的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的场地魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将卡组中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组把1张场地魔法卡加入手牌，并向对方确认。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的场地魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认所加入的手牌卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
