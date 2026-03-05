--Sin Selector
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地把2张「罪」卡除外才能发动。和除外的卡卡名不同的「罪 选择」以外的2张「罪」卡从卡组加入手卡（同名卡最多1张）。
function c18378992.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
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
-- 效果作用：过滤满足条件的「罪」卡（可除外）
function c18378992.cfilter(c)
	return c:IsSetCard(0x23) and c:IsAbleToRemoveAsCost()
end
-- 效果作用：过滤满足条件的「罪」卡（可加入手牌且卡名与除外卡不同）
function c18378992.thfilter(c,code1,code2)
	return c:IsSetCard(0x23) and c:IsAbleToHand() and not c:IsCode(18378992,code1,code2)
end
-- 效果作用：检查是否满足除外2张卡后能从卡组检索2张不同卡名的「罪」卡
function c18378992.costcheck(g,tp)
	local code1=g:GetFirst():GetCode()
	local code2=g:GetNext():GetCode()
	-- 效果作用：检索满足条件的「罪」卡
	local tg=Duel.GetMatchingGroup(c18378992.thfilter,tp,LOCATION_DECK,0,nil,code1,code2)
	return tg:GetClassCount(Card.GetCode)>=2
end
-- 效果作用：设置发动标记
function c18378992.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 效果作用：处理发动时的除外费用并设置检索目标
function c18378992.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检索满足条件的「罪」卡（墓地）
	local g=Duel.GetMatchingGroup(c18378992.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return g:CheckSubGroup(c18378992.costcheck,2,2,tp)
	end
	-- 效果作用：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c18378992.costcheck,false,2,2,tp)
	-- 效果作用：将选中的卡除外
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	sg:KeepAlive()
	e:SetLabelObject(sg)
	e:SetLabel(0)
	-- 效果作用：设置连锁操作信息（回手牌）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果作用：处理效果发动后的检索与加入手牌
function c18378992.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local code1=g:GetFirst():GetCode()
	local code2=g:GetNext():GetCode()
	-- 效果作用：检索满足条件的「罪」卡
	local tg=Duel.GetMatchingGroup(c18378992.thfilter,tp,LOCATION_DECK,0,nil,code1,code2)
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：选择满足条件的2张不同卡名的「罪」卡
	local sg=tg:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 效果作用：将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 效果作用：确认对方手牌
		Duel.ConfirmCards(1-tp,sg)
	end
end
