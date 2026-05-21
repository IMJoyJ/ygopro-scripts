--俊炎星－ゾウセイ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地才能发动。从手卡把「俊炎星-象清」以外的1只「炎星」怪兽特殊召唤。
-- ②：以自己墓地1张「炎舞」魔法·陷阱卡为对象才能发动。那张卡回到卡组。那之后，可以从卡组把1只5星以上的「炎星」怪兽加入手卡。
function c98093548.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地才能发动。从手卡把「俊炎星-象清」以外的1只「炎星」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98093548,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,98093548)
	e1:SetCost(c98093548.spcost)
	e1:SetTarget(c98093548.sptg)
	e1:SetOperation(c98093548.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以自己墓地1张「炎舞」魔法·陷阱卡为对象才能发动。那张卡回到卡组。那之后，可以从卡组把1只5星以上的「炎星」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(98093548,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,98093549)
	e3:SetTarget(c98093548.tdtg)
	e3:SetOperation(c98093548.tdop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「炎舞」魔法·陷阱卡且能送去墓地
function c98093548.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价判定：检查场上是否有可送去墓地的「炎舞」魔陷，或者是否适用「炎星仙-鹫真人」的代替效果
function c98093548.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1张满足条件的「炎舞」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c98093548.costfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		or Duel.IsPlayerAffectedByEffect(tp,46241344) end
	-- 如果自己场上存在满足条件的「炎舞」魔法·陷阱卡
	if Duel.IsExistingMatchingCard(c98093548.costfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		and (not Duel.IsPlayerAffectedByEffect(tp,46241344) or not Duel.SelectYesNo(tp,aux.Stringid(46241344,0))) then  --"是否不把卡送去墓地发动？"
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 玩家选择自己场上1张表侧表示的「炎舞」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c98093548.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 将选择的卡送去墓地作为发动代价
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- 过滤条件：手卡中「俊炎星-象清」以外的、可以特殊召唤的「炎星」怪兽
function c98093548.spfilter(c,e,tp)
	return c:IsSetCard(0x79) and not c:IsCode(98093548) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查怪兽区域空位以及手卡中是否存在可特殊召唤的「炎星」怪兽
function c98093548.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡中是否存在满足特殊召唤条件的「炎星」怪兽
		and Duel.IsExistingMatchingCard(c98093548.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理：从手卡特殊召唤1只「俊炎星-象清」以外的「炎星」怪兽
function c98093548.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足条件的「炎星」怪兽
	local g=Duel.SelectMatchingCard(tp,c98093548.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己墓地中可以回到卡组的「炎舞」魔法·陷阱卡
function c98093548.tdfilter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 效果②的发动准备：选择自己墓地1张「炎舞」魔法·陷阱卡为对象
function c98093548.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c98093548.tdfilter(chkc) end
	-- 检查自己墓地是否存在满足条件的「炎舞」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c98093548.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择自己墓地1张「炎舞」魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c98093548.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置回到卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 过滤条件：卡组中5星以上、可以加入手卡的「炎星」怪兽
function c98093548.thfilter(c)
	return c:IsSetCard(0x79) and c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的效果处理：使作为对象的卡回到卡组，之后可以从卡组把1只5星以上的「炎星」怪兽加入手卡
function c98093548.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍适用此效果，则将其送回卡组并洗牌。若成功回到卡组，则继续处理
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) then
		-- 获取卡组中所有满足条件的5星以上的「炎星」怪兽
		local g=Duel.GetMatchingGroup(c98093548.thfilter,tp,LOCATION_DECK,0,nil)
		-- 若卡组中存在满足条件的怪兽，玩家可以选择是否将其加入手卡
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(98093548,2)) then  --"是否从卡组把「炎星」怪兽加入手卡？"
			-- 中断当前效果，使后续的检索处理与回到卡组不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要加入手卡的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选择的怪兽加入手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 让对方玩家确认加入手卡的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
