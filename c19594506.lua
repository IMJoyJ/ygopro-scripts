--ネオスペース・コンダクター
-- 效果：
-- 把这张卡从手卡丢弃去墓地。把自己的卡组或者墓地存在的1张「新宇宙」加入手卡。
function c19594506.initial_effect(c)
	-- 把这张卡从手卡丢弃去墓地。把自己的卡组或者墓地存在的1张「新宇宙」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19594506,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c19594506.cost)
	e1:SetTarget(c19594506.target)
	e1:SetOperation(c19594506.operation)
	c:RegisterEffect(e1)
end
-- 将此卡从手卡丢弃作为费用
function c19594506.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将此卡送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡片编号为42015635且可以加入手牌
function c19594506.filter(c)
	return c:IsCode(42015635) and c:IsAbleToHand()
end
-- 设置连锁处理信息，表示将从卡组或墓地检索一张「新宇宙」加入手牌
function c19594506.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或墓地是否存在满足条件的「新宇宙」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c19594506.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁处理信息，表示将从卡组或墓地检索一张「新宇宙」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 选择并把符合条件的「新宇宙」加入手牌
function c19594506.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择一张满足条件的「新宇宙」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19594506.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「新宇宙」加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
