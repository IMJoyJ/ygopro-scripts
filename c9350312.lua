--丘と芽吹の春化精
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡和1只怪兽或者和1张「春化精」卡从手卡丢弃才能发动。从卡组把「丘与发芽的春化精」以外的1张「春化精」卡加入手卡。那之后，可以从自己墓地选1只地属性怪兽特殊召唤。这个回合，自己不能把地属性以外的怪兽的效果发动。
-- ②：只要这张卡在怪兽区域存在，自己场上的「春化精」怪兽不会被效果破坏。
function c9350312.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：把这张卡和1只怪兽或者和1张「春化精」卡从手卡丢弃才能发动。从卡组把「丘与发芽的春化精」以外的1张「春化精」卡加入手卡。那之后，可以从自己墓地选1只地属性怪兽特殊召唤。这个回合，自己不能把地属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,9350312)
	e1:SetCost(c9350312.thcost)
	e1:SetTarget(c9350312.thtg)
	e1:SetOperation(c9350312.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的「春化精」怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c9350312.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中除自身以外的1只怪兽或者1张「春化精」卡，且可以丢弃
function c9350312.costfilter(c)
	return (c:IsType(TYPE_MONSTER) or c:IsSetCard(0x182)) and c:IsDiscardable()
end
-- ①效果的发动代价（丢弃自身和手卡的1只怪兽或1张「春化精」卡）
function c9350312.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家是否受到「春化精的花冠」效果的影响（代替丢弃手卡）
	local fe=Duel.IsPlayerAffectedByEffect(tp,14108995)
	-- 检查手卡中是否存在除这张卡以外可以作为丢弃代价的卡
	local b2=Duel.IsExistingMatchingCard(c9350312.costfilter,tp,LOCATION_HAND,0,1,c)
	if chk==0 then return c:IsDiscardable() and (fe or b2) end
	-- 如果适用「春化精的花冠」的效果，且玩家选择适用或没有其他可丢弃的卡
	if fe and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(14108995,0))) then  --"是否适用「春化精的花冠」的效果？"
		-- 在场上展示「春化精的花冠」卡片以示适用其效果
		Duel.Hint(HINT_CARD,0,14108995)
		fe:UseCountLimit(tp)
		-- 将这张卡作为发动代价丢弃送去墓地
		Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
	else
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 让玩家选择1张手卡中满足条件的卡作为丢弃代价
		local g=Duel.SelectMatchingCard(tp,c9350312.costfilter,tp,LOCATION_HAND,0,1,1,c)
		g:AddCard(c)
		-- 将选中的卡作为发动代价丢弃送去墓地
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	end
end
-- 过滤条件：卡组中「丘与发芽的春化精」以外的1张「春化精」卡，且可以加入手卡
function c9350312.thfilter(c)
	return c:IsSetCard(0x182) and not c:IsCode(9350312) and c:IsAbleToHand()
end
-- ①效果的发动准备（检查卡组中是否有可检索的卡并设置操作信息）
function c9350312.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c9350312.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息：包含从卡组将1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：墓地中的地属性怪兽，且可以特殊召唤
function c9350312.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的效果处理（检索「春化精」卡，并可选特殊召唤墓地的地属性怪兽，最后施加属性限制）
function c9350312.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「春化精」卡
	local g=Duel.SelectMatchingCard(tp,c9350312.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果成功将选中的卡加入手卡
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 获取自己墓地中不受「王家长眠之谷」影响且满足特殊召唤条件的地属性怪兽
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c9350312.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 如果墓地存在可特殊召唤的怪兽且自己场上有空余的怪兽区域
		if sg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 询问玩家是否选择从墓地特殊召唤怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(9350312,0)) then  --"是否从墓地特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤处理与检索处理不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=sg:Select(tp,1,1,nil)
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不能把地属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c9350312.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该回合内不能发动地属性以外怪兽效果的限制
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能发动地属性以外的怪兽的效果
function c9350312.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsNonAttribute(ATTRIBUTE_EARTH)
end
-- 过滤条件：自己场上表侧表示的「春化精」怪兽
function c9350312.indtg(e,c)
	return c:IsSetCard(0x182) and c:IsFaceup()
end
