--竜華界闢
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1只「龙华」怪兽加入手卡。那之后，可以从手卡把1只「龙华」灵摆怪兽表侧加入额外卡组。
-- ②：自己场上有「龙华」灵摆怪兽卡存在的场合，自己主要阶段，从自己墓地把1只「龙华」怪兽和这张卡除外才能发动。原本种族和除外的怪兽相同的1只「龙华」怪兽从卡组特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：①为发动时检索「龙华」怪兽并可将手卡「龙华」灵摆怪兽表侧加入额外卡组；②为墓地起动效果，除外自身和1只「龙华」怪兽，从卡组特殊召唤1只原本种族相同的「龙华」怪兽。
function s.initial_effect(c)
	-- ①：从卡组把1只「龙华」怪兽加入手卡。那之后，可以从手卡把1只「龙华」灵摆怪兽表侧加入额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索后灵摆卡加入额外卡组"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「龙华」灵摆怪兽卡存在的场合，自己主要阶段，从自己墓地把1只「龙华」怪兽和这张卡除外才能发动。原本种族和除外的怪兽相同的1只「龙华」怪兽从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 检索过滤：判断卡组中的卡是否为「龙华」怪兽且可以被加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1c0) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动时点判定：确认卡组存在可加入手卡的「龙华」怪兽，并设置处理信息为从卡组将1张卡加入手卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中是否存在1张以上可以加入手卡的「龙华」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理包含从卡组将1张卡加入手卡的分类，供后续时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 额外卡组过滤：判断手卡中的卡是否为「龙华」灵摆怪兽且可以表侧加入额外卡组。
function s.exfilter(c)
	return c:IsSetCard(0x1c0) and c:IsType(TYPE_PENDULUM) and c:IsAbleToExtra()
end
-- ①效果处理：从卡组选择1只「龙华」怪兽加入手卡并展示给对方，然后询问玩家是否将手卡中的「龙华」灵摆怪兽表侧加入额外卡组，若选择是则检索并加入额外卡组。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「龙华」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 检查手卡中是否存在符合条件的「龙华」灵摆怪兽。
		if Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_HAND,0,1,nil)
			-- 询问玩家是否将手卡的「龙华」灵摆怪兽表侧加入额外卡组。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否加入额外卡组？"
			-- 提示玩家选择要加入额外卡组的卡。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择要加入额外卡组的卡"
			-- 从手卡选择1张符合条件的「龙华」灵摆怪兽。
			local teg=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_HAND,0,1,1,nil)
			if teg:GetCount()>0 then
				-- 洗切手卡，因为从手卡选了卡后需要重新洗切。
				Duel.ShuffleHand(tp)
				-- 中断当前效果链，使之后加入额外卡组的处理与之前的检索处理视为不同时点，避免错过时点。
				Duel.BreakEffect()
				-- 将选择的灵摆怪兽表侧加入其持有者的额外卡组。
				Duel.SendtoExtraP(teg,nil,REASON_EFFECT)
			end
		end
	end
end
-- 条件过滤：判断场上的卡是否为表侧表示的「龙华」灵摆怪兽。
function s.cofilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x1c0)
end
-- ②效果的发动条件判定：自己场上有表侧表示的「龙华」灵摆怪兽卡存在。
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在1张以上表侧表示的「龙华」灵摆怪兽。
	return Duel.IsExistingMatchingCard(s.cofilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 代价过滤：判断墓地中的卡是否为「龙华」怪兽且可作为代价除外，同时卡组中存在与其原本种族相同的可特殊召唤的「龙华」怪兽。
function s.cfilter(c,e,tp)
	return c:IsSetCard(0x1c0) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 确认卡组中存在与墓地这只怪兽原本种族相同的可特殊召唤的「龙华」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetOriginalRace())
end
-- 特殊召唤过滤：判断卡组中的卡是否为「龙华」怪兽，且原本种族与除外的怪兽相同，并且可以被特殊召唤。
function s.spfilter(c,e,tp,race)
	return c:IsSetCard(0x1c0) and c:GetOriginalRace()==race
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动代价判定：先设置标记，然后检查这张卡自身和墓地中是否存在可作为代价除外的符合条件的「龙华」怪兽。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查墓地中是否存在1张以上符合条件的「龙华」怪兽可作为代价除外。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1张符合条件的「龙华」怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local race=g:GetFirst():GetOriginalRace()
	g:AddCard(e:GetHandler())
	-- 将选中的墓地怪兽和这张卡（自身）以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(100,race)
end
-- ②效果发动时点判定：确认已经支付过代价标记且自己场上有空位，并设置处理信息为从卡组特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已经执行过代价处理（标记为100）且自己场上有可用的怪兽区域。
	if chk==0 then return e:GetLabel()==100 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置操作信息：本次效果处理包含从卡组特殊召唤1只怪兽的分类。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：根据记录的原种族从卡组选择1只符合条件的「龙华」怪兽特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local lab,race=e:GetLabel()
	-- 处理时再次确认自己场上是否有可用怪兽区域，没有则特殊召唤处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张符合条件的「龙华」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,race)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
