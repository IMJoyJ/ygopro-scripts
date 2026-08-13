--Sin Selector
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地把2张「罪」卡除外才能发动。和除外的卡卡名不同的「罪 选择」以外的2张「罪」卡从卡组加入手卡（同名卡最多1张）。
function c18378992.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己墓地把2张「罪」卡除外才能发动。和除外的卡卡名不同的「罪 选择」以外的2张「罪」卡从卡组加入手卡（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,18378992+EFFECT_COUNT_CODE_OATH)
	e1:SetLabel(0)
	e1:SetCost(c18378992.cost)
	e1:SetTarget(c18378992.target)
	e1:SetOperation(c18378992.operation)
	c:RegisterEffect(e1)
end
-- 筛选墓地中满足「罪」字段且可以作为代价除外的卡。
function c18378992.cfilter(c)
	return c:IsSetCard(0x23) and c:IsAbleToRemoveAsCost()
end
-- 筛选卡组中满足「罪」字段、可以加入手卡，且卡名既不是「罪 选择」，也不是除外的那两张卡的卡名的卡。
function c18378992.thfilter(c,code1,code2)
	return c:IsSetCard(0x23) and c:IsAbleToHand() and not c:IsCode(18378992,code1,code2)
end
-- 检查组内两张「罪」卡的卡名，再从卡组中筛选符合条件的卡，确保可检索的卡名种类数不少于2，以保证能检索2张与除外卡卡名不同且互不同名的「罪」卡。
function c18378992.costcheck(g,tp)
	local code1=g:GetFirst():GetCode()
	local code2=g:GetNext():GetCode()
	-- 获取卡组中所有满足条件的「罪」卡（排除除外的那两张卡名和本卡名），用于检查可检索的种类数。
	local tg=Duel.GetMatchingGroup(c18378992.thfilter,tp,LOCATION_DECK,0,nil,code1,code2)
	return tg:GetClassCount(Card.GetCode)>=2
end
-- 代价函数：先给效果标记设为100并返回true，配合target阶段确认已经进入代价处理，实际选卡和除外在target阶段进行。
function c18378992.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 目标处理：获取墓地中可作代价的「罪」卡，检查能否选出2张且能检索2张卡名不同的「罪」卡；若满足，则让玩家选择2张除外作为代价，并设定随后从卡组将2张卡加入手卡的操作信息。
function c18378992.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取我方墓地中所有可以作为代价除外的「罪」卡。
	local g=Duel.GetMatchingGroup(c18378992.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return g:CheckSubGroup(c18378992.costcheck,2,2,tp)
	end
	-- 向玩家显示「请选择要除外的卡」的提示，用于选择卡片时的消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c18378992.costcheck,false,2,2,tp)
	-- 将选中的2张「罪」卡以表侧表示除外，作为发动代价。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	sg:KeepAlive()
	e:SetLabelObject(sg)
	e:SetLabel(0)
	-- 设定效果处理信息：预计从卡组将2张卡加入手卡，目标为自己，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：根据除外的那两张卡的卡名，从卡组筛选符合条件的「罪」卡，让玩家选择2张卡名互不相同的卡加入手牌，并展示给对方确认。
function c18378992.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local code1=g:GetFirst():GetCode()
	local code2=g:GetNext():GetCode()
	-- 获取卡组中所有满足条件的「罪」卡（排除除外卡卡名和本卡名），供玩家选择。
	local tg=Duel.GetMatchingGroup(c18378992.thfilter,tp,LOCATION_DECK,0,nil,code1,code2)
	-- 向玩家显示「请选择要加入手牌的卡」的提示，用于选择卡片时的消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从符合条件的卡中让玩家选择2张卡名互不相同的「罪」卡。
	local sg=tg:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 将选中的2张「罪」卡加入持有者的手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
