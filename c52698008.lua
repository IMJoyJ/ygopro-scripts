--サイバース・ウィキッド
-- 效果：
-- 电子界族怪兽2只
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：连接召唤的这张卡不会被战斗·效果破坏。
-- ②：这张卡所连接区的电子界族怪兽不会被效果破坏。
-- ③：这张卡已在怪兽区域存在的状态，这张卡所连接区有怪兽特殊召唤的场合，从自己墓地把1只电子界族怪兽除外才能发动。从卡组把1只电子界族调整加入手卡。
function c52698008.initial_effect(c)
	-- 为这张卡添加连接召唤手续，要求用2只电子界族怪兽作为连接素材（对应效果原文‘电子界族怪兽2只’）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	c:EnableReviveLimit()
	-- ①：连接召唤的这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c52698008.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：这张卡所连接区的电子界族怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c52698008.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡在怪兽区域存在的状态，这张卡所连接区有怪兽特殊召唤的场合，从自己墓地把1只电子界族怪兽除外才能发动。从卡组把1只电子界族调整加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(52698008,0))  --"卡组检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,52698008)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c52698008.thcon)
	e4:SetCost(c52698008.thcost)
	e4:SetTarget(c52698008.thtg)
	e4:SetOperation(c52698008.thop)
	c:RegisterEffect(e4)
end
-- 抗性效果的条件：效果持有者是通过连接召唤出场的怪兽。
function c52698008.indcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ②效果的适用对象判定：对象怪兽必须是电子界族，且位于这张卡的连接区域内；满足条件时对其赋予‘不会被效果破坏’抗性。
function c52698008.indtg(e,c)
	return c:IsRace(RACE_CYBERSE) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 用于判定特殊召唤的怪兽是否被特殊召唤到这张卡所连接区；若该怪兽当前仍在场上，直接检查连接区是否包含它；若已离场，则根据其特殊召唤成功前所在的位置（所属玩家与区域序号）判断是否属于这张卡的连接区。
function c52698008.thcfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return ec:GetLinkedGroup():IsContains(c)
	else
		return bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- ③效果的触发条件：当这张卡已在怪兽区域存在时，有其他怪兽被特殊召唤到这张卡的连接区，且该怪兽不是这张卡自身。
function c52698008.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not eg:IsContains(c) and eg:IsExists(c52698008.thcfilter,1,nil,c)
end
-- 代价筛选：选择自己墓地的1只电子界族怪兽，要求可作为除外代价。
function c52698008.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_CYBERSE) and c:IsAbleToRemoveAsCost()
end
-- ③效果的发动代价：从自己墓地选择1只电子界族怪兽以表侧表示除外，才能发动。
function c52698008.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己墓地是否存在至少1只符合条件的电子界族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c52698008.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足cfilter条件的电子界族怪兽。
	local g=Duel.SelectMatchingCard(tp,c52698008.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡片以表侧表示除外，作为发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检索目标筛选：卡组中的电子界族调整怪兽，且能够加入手卡。
function c52698008.thfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- ③效果的目标确认与操作信息设置：确认卡组存在电子界族调整，并声明本次处理为从卡组加入手卡。
function c52698008.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检测：检查卡组是否存在至少1张符合条件的电子界族调整怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c52698008.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理为从卡组把1张卡加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果结算：从卡组选择1只电子界族调整怪兽加入手卡，并向对方展示。
function c52698008.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足thfilter条件的电子界族调整怪兽。
	local g=Duel.SelectMatchingCard(tp,c52698008.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手卡（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手展示加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
