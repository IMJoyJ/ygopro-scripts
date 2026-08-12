--善悪の彼岸
-- 效果：
-- 「彼岸的鬼神 马拉布兰卡」的降临必需。「善恶的彼岸」的②的效果1回合只能使用1次。
-- ①：从自己的手卡·场上把等级合计直到6以上的怪兽解放，从手卡把「彼岸的鬼神 马拉布兰卡」仪式召唤。
-- ②：自己主要阶段把墓地的这张卡除外，从手卡把1只「彼岸」怪兽送去墓地才能发动。从卡组把1张「彼岸」卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c62835876.initial_effect(c)
	-- 注册作为「彼岸的鬼神 马拉布兰卡」降临必需的仪式召唤效果，解放等级合计直到6以上
	aux.AddRitualProcGreaterCode(c,35330871)
	-- 「善恶的彼岸」的②的效果1回合只能使用1次。②：自己主要阶段把墓地的这张卡除外，从手卡把1只「彼岸」怪兽送去墓地才能发动。从卡组把1张「彼岸」卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,62835876)
	-- 设置效果发动条件：这张卡送去墓地的回合不能发动
	e1:SetCondition(aux.exccon)
	e1:SetCost(c62835876.thcost)
	e1:SetTarget(c62835876.thtg)
	e1:SetOperation(c62835876.thop)
	c:RegisterEffect(e1)
end
-- 过滤条件：手牌中可以作为代价送去墓地的「彼岸」怪兽
function c62835876.cfilter(c)
	return c:IsSetCard(0xb1) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 代价检测：检查自身是否能除外，以及手牌中是否存在可送去墓地的「彼岸」怪兽
function c62835876.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查手牌中是否存在至少1张满足条件的「彼岸」怪兽
		and Duel.IsExistingMatchingCard(c62835876.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 作为发动代价，将墓地的这张卡除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 作为发动代价，从手牌将1只「彼岸」怪兽送去墓地
	Duel.DiscardHand(tp,c62835876.cfilter,1,1,REASON_COST,nil)
end
-- 过滤条件：卡组中可以加入手牌的「彼岸」卡
function c62835876.filter(c)
	return c:IsSetCard(0xb1) and c:IsAbleToHand()
end
-- 靶向/发动准备：检查卡组中是否存在可检索的「彼岸」卡，并设置检索的操作信息
function c62835876.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「彼岸」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c62835876.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组将1张「彼岸」卡加入手牌并给对方确认
function c62835876.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「彼岸」卡
	local g=Duel.SelectMatchingCard(tp,c62835876.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
