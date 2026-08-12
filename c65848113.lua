--終刻竜機ⅩⅢ－グラフレイオ
-- 效果：
-- 5星怪兽×3
-- 「终刻龙机13-格拉弗莱伊俄」1回合1次也能在自己场上的「终刻」超量怪兽上面重叠来超量召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「终刻」魔法·陷阱卡加入手卡。那之后，可以把场上1张卡破坏。
-- ②：这张卡被效果破坏的场合才能发动。从自己的卡组·墓地把超量怪兽以外的1只「终刻」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：设置超量召唤手续（可在「终刻」超量怪兽上重叠）、①效果（检索并可选破坏）、②效果（被效果破坏时特召）。
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,5,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)  --"是否在超量怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「终刻」魔法·陷阱卡加入手卡。那之后，可以把场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果破坏的场合才能发动。从自己的卡组·墓地把超量怪兽以外的1只「终刻」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「终刻」超量怪兽。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d2) and c:IsType(TYPE_XYZ)
end
-- 超量召唤时的操作：检查并注册该特殊超量召唤方式的每回合1次限制。
function s.xyzop(e,tp,chk)
	-- 检查本回合是否已使用过该方式进行超量召唤。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 注册本回合已使用该方式超量召唤的标记。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- ①效果的发动成本（Cost）：取除这张卡的1个超量素材。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：卡组中的「终刻」魔法·陷阱卡。
function s.thfilter(c)
	return c:IsSetCard(0x1d2) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动准备（Target）：检查卡组中是否存在可检索的卡，并设置检索的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「终刻」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理（Operation）：从卡组将1张「终刻」魔法·陷阱卡加入手卡，之后可选择破坏场上1张卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的「终刻」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND)
			-- 检查场上是否存在可以破坏的卡。
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否选择进行破坏效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把卡破坏？"
			-- 提示玩家选择要破坏的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择场上1张卡片。
			local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #dg>0 then
				-- 中断效果处理，使后续的破坏处理与加入手卡不视为同时进行。
				Duel.BreakEffect()
				-- 闪烁显示被选择的破坏目标。
				Duel.HintSelection(dg)
				-- 将选择的卡片破坏。
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
end
-- ②效果的发动条件：这张卡被效果破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
-- 过滤条件：卡组·墓地中超量怪兽以外的、可以特殊召唤的「终刻」怪兽。
function s.spfilter(c,e,tp)
	return not c:IsType(TYPE_XYZ) and c:IsSetCard(0x1d2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备（Target）：检查怪兽区域空位以及是否存在可特召的怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组或墓地中是否存在满足条件的「终刻」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组·墓地将1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的处理（Operation）：从卡组·墓地选择1只超量怪兽以外的「终刻」怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域空位，若无空位则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组·墓地选择1只满足条件且不受「王家长眠之谷」影响的「终刻」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
