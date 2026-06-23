--雙王の械
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1张「破械」卡加入手卡。
-- ②：盖放的这张卡被效果破坏的场合才能发动。从卡组把1只「破械」怪兽特殊召唤。
function c27412542.initial_effect(c)
	-- ①：从卡组把1张「破械」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27412542,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,27412542)
	e1:SetTarget(c27412542.target)
	e1:SetOperation(c27412542.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被效果破坏的场合才能发动。从卡组把1只「破械」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27412542,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,27412543)
	e2:SetCondition(c27412542.spcon)
	e2:SetTarget(c27412542.sptg)
	e2:SetOperation(c27412542.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选「破械」卡且能加入手牌的卡片。
function c27412542.filter(c)
	return c:IsSetCard(0x130) and c:IsAbleToHand()
end
-- 效果的发动时点处理函数，检查是否满足检索条件。
function c27412542.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「破械」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c27412542.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示将从卡组检索1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的发动处理函数，执行检索并加入手牌的操作。
function c27412542.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「破械」卡。
	local g=Duel.SelectMatchingCard(tp,c27412542.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否满足特殊召唤条件，即该卡因效果被破坏且为盖放状态。
function c27412542.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤函数，用于筛选「破械」怪兽且能特殊召唤的卡片。
function c27412542.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动时点处理函数，检查是否满足召唤条件。
function c27412542.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查召唤者场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在满足条件的「破械」怪兽。
		and Duel.IsExistingMatchingCard(c27412542.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的发动处理函数，执行特殊召唤的操作。
function c27412542.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查召唤者场上是否有空位，若无则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「破械」怪兽。
	local g=Duel.SelectMatchingCard(tp,c27412542.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
