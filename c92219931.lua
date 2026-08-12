--二者一両損
-- 效果：
-- 双方互相把自己卡组最上面的1张卡送去墓地。
function c92219931.initial_effect(c)
	-- 双方互相把自己卡组最上面的1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c92219931.discost)
	e1:SetOperation(c92219931.disop)
	c:RegisterEffect(e1)
end
-- 发动条件与效果处理的准备：检查双方是否能将卡组顶端的卡送去墓地，并设置送去墓地的操作信息
function c92219931.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方玩家是否都可以将卡组最上面1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.IsPlayerCanDiscardDeck(1-tp,1) end
	-- 设置操作信息，表示该效果包含将双方卡组的卡送去墓地的处理
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,1)
end
-- 效果处理：将双方卡组最上面的1张卡送去墓地
function c92219931.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 将玩家0（先攻玩家）卡组最上面的1张卡送去墓地
	Duel.DiscardDeck(0,1,REASON_EFFECT)
	-- 将玩家1（后攻玩家）卡组最上面的1张卡送去墓地
	Duel.DiscardDeck(1,1,REASON_EFFECT)
end
