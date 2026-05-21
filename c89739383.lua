--グリモの魔導書
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把「奥义之魔导书」以外的1张「魔导书」卡加入手卡。
function c89739383.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把「奥义之魔导书」以外的1张「魔导书」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,89739383+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c89739383.target)
	e1:SetOperation(c89739383.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中「奥义之魔导书」以外的「魔导书」卡片，且该卡片可以加入手卡
function c89739383.filter(c)
	return c:IsSetCard(0x106e) and not c:IsCode(89739383) and c:IsAbleToHand()
end
-- 效果发动的准备阶段，检查卡组中是否存在符合条件的卡，并设置将卡片加入手卡的操作信息
function c89739383.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查卡组中是否存在至少1张「奥义之魔导书」以外的「魔导书」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c89739383.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果的处理是将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行，让玩家从卡组选择1张符合条件的卡加入手卡并给对方确认
function c89739383.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张「奥义之魔导书」以外的「魔导书」卡片
	local g=Duel.SelectMatchingCard(tp,c89739383.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
