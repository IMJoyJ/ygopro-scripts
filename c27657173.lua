--真紅眼の黒星竜
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡·卡组把1只5星以上的通常怪兽送去墓地才能发动。这张卡从手卡特殊召唤。那之后，这张卡的等级上升1星。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从自己的卡组·墓地把1张「真红眼融合」加入手卡。
function c27657173.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从手卡·卡组把1只5星以上的通常怪兽送去墓地才能发动。这张卡从手卡特殊召唤。那之后，这张卡的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,27657173)
	e1:SetCost(c27657173.spcost)
	e1:SetTarget(c27657173.sptg)
	e1:SetOperation(c27657173.spop)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从自己的卡组·墓地把1张「真红眼融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,27657174)
	-- 设置②效果的发动条件：这张卡不是在本回合被送去墓地（或满足返回手牌等重置情况），对应‘这个回合没有送去墓地的这张卡’的限制。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：将这张卡从墓地除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c27657173.thtg)
	e2:SetOperation(c27657173.thop)
	c:RegisterEffect(e2)
end
-- 定义①效果代价的过滤器：选择通常怪兽、等级5以上且可以作为代价送去墓地的卡。
function c27657173.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelAbove(5) and c:IsAbleToGraveAsCost()
end
-- ①效果的代价函数：检查并执行从手卡·卡组选择1只5星以上的通常怪兽送去墓地作为发动代价。
function c27657173.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认手卡·卡组中存在符合条件的通常怪兽，才允许发动①效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c27657173.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 弹出选择提示，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手卡·卡组选择1张满足条件的通常怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c27657173.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 将选择的怪兽送去墓地，原因标记为代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果发动时的目标函数：检查特殊召唤条件并登记操作信息。
function c27657173.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查：自己主要怪兽区有空位，且这张卡自身可被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：将这张卡特殊召唤，供连锁反应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理的执行函数：实际进行特殊召唤，并在成功后提升等级。
function c27657173.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时确认这张卡仍与效果关联且特殊召唤成功（召唤上场）后，进入后续等级提升处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断当前效果链，使特殊召唤与随后的等级提升作为不同时点处理，对应‘那之后’。
		Duel.BreakEffect()
		-- 那之后，这张卡的等级上升1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	end
end
-- 定义②效果检索目标的过滤器：卡名是『真红眼融合』且可以加入手卡。
function c27657173.thfilter(c)
	return c:IsCode(6172122) and c:IsAbleToHand()
end
-- ②效果的目标函数：检查卡组·墓地是否存在符合条件的『真红眼融合』并登记操作信息。
function c27657173.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查：卡组·墓地存在至少1张『真红眼融合』且可以加入手卡，才可发动②效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c27657173.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 登记操作信息：从卡组·墓地加入手卡1张卡，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理的执行函数：实际将『真红眼融合』加入手卡并向对方展示。
function c27657173.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组·墓地选择1张符合条件的『真红眼融合』，同时过滤掉受王家长眠之谷影响而不能从墓地取回的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27657173.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡送入其持有者的手卡，原因为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
