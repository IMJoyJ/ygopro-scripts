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
-- 作为发动效果的COST处理：判定这张卡能否从手卡丢弃去墓地，满足后即将其送入墓地。
function c19594506.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将这张卡以『丢弃』这一代价从手卡送去墓地（REASON_COST+REASON_DISCARD）。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 定义检索条件：必须是卡号为42015635的「新宇宙」，且能够被加入手卡。
function c19594506.filter(c)
	return c:IsCode(42015635) and c:IsAbleToHand()
end
-- target函数：效果发动时检查是否存在可检索的「新宇宙」，并声明本次效果将把1张「新宇宙」加入手卡。
function c19594506.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：确认自己的卡组或墓地中是否存在至少1张符合filter条件的「新宇宙」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c19594506.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：将本次效果登记为『加入手卡』，预定从卡组或墓地处理1张卡，操作玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：从自己的卡组或墓地选择1张「新宇宙」（墓地中被王家长眠之谷影响的卡除外）加入手卡，并向对方确认。
function c19594506.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组或墓地中选出1张符合条件的「新宇宙」；aux.NecroValleyFilter用于排除墓地中受王家长眠之谷影响而无法加入手卡的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19594506.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「新宇宙」卡以效果原因（REASON_EFFECT）加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
