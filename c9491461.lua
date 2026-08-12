--ガガガガンバラナイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把额外卡组1只「我我我」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。那之后，可以从以下效果选1个适用。
-- ●从手卡把1只「我我我」怪兽特殊召唤。
-- ●场上1只怪兽的表示形式变更。
-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动。从卡组把1只「隆隆隆」怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡特召+后续效果）和②效果（作为超量素材被取除时检索）。
function s.initial_effect(c)
	-- ①：把额外卡组1只「我我我」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。那之后，可以从以下效果选1个适用。●从手卡把1只「我我我」怪兽特殊召唤。●场上1只怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动。从卡组把1只「隆隆隆」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_MOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤额外卡组中未给对方确认过的「我我我」怪兽。
function s.cfilter(c)
	return c:IsSetCard(0x54) and not c:IsPublic()
end
-- ①效果的发动代价：从额外卡组选择1只「我我我」怪兽给对方观看。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以给对方观看的「我我我」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择额外卡组的1只「我我我」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的怪兽给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
end
-- 过滤手卡中可以特殊召唤的「我我我」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x54) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备：检查自身是否能从手卡特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：特殊召唤自身，并根据玩家选择适用后续效果（特召手卡「我我我」或变更场上怪兽表示形式）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 将自身以表侧表示特殊召唤，若特殊召唤失败则不处理后续效果。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 检查自己场上是否有可用的怪兽区域，作为后续特召效果的可行性条件。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在可以特殊召唤的「我我我」怪兽，作为后续特召效果的可行性条件。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	-- 检查场上是否存在可以变更表示形式的怪兽，作为后续变更表示形式效果的可行性条件。
	local b2=Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 让玩家从可用的后续效果中选择一个适用（或者不处理）。
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},  --"特殊召唤"
		{b2,aux.Stringid(id,3),2},  --"表示形式变更"
		{true,aux.Stringid(id,4),3})  --"不处理效果"
	if op==1 then
		-- 中断当前效果处理，使后续的特殊召唤处理与之前的特殊召唤不视为同时进行。
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家选择手卡中1只满足条件的「我我我」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「我我我」怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		-- 中断当前效果处理，使后续的变更表示形式处理与之前的特殊召唤不视为同时进行。
		Duel.BreakEffect()
		-- 提示玩家选择要改变表示形式的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 玩家选择场上1只可以变更表示形式的怪兽。
		local g=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		-- 显式提示被选中的怪兽。
		Duel.HintSelection(g)
		-- 改变选中怪兽的表示形式。
		Duel.ChangePosition(g:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- ②效果的发动条件：此卡作为超量素材，为了发动超量怪兽的效果而被取除并移动位置的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 过滤卡组中可以加入手卡的「隆隆隆」怪兽。
function s.thfilter(c)
	return c:IsSetCard(0x59) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动准备：检查卡组中是否存在可检索的「隆隆隆」怪兽，并设置检索的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「隆隆隆」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组选择1只「隆隆隆」怪兽加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择卡组中1只「隆隆隆」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
