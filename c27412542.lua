--雙王の械
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1张「破械」卡加入手卡。
-- ②：盖放的这张卡被效果破坏的场合才能发动。从卡组把1只「破械」怪兽特殊召唤。
function c27412542.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次；①：从卡组把1张「破械」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27412542,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,27412542)
	e1:SetTarget(c27412542.target)
	e1:SetOperation(c27412542.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次；②：盖放的这张卡被效果破坏的场合才能发动。从卡组把1只「破械」怪兽特殊召唤。
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
-- 定义①效果检索用的过滤器：卡必须属于「破械」系列字段，并且能够被加入手卡。
function c27412542.filter(c)
	return c:IsSetCard(0x130) and c:IsAbleToHand()
end
-- ①效果的发动条件和操作信息设定函数：在发动时确认卡组存在符合条件的「破械」卡，并标记本次处理为检索加入手卡。
function c27412542.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时点判定：卡组是否存在至少1张满足filter条件的「破械」卡，以决定该效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c27412542.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定操作信息：将本次效果处理登记为从卡组将1张卡加入手卡（CATEGORY_TOHAND+CATEGORY_SEARCH），数量为1，来源是当前玩家的卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：实际从卡组选择1张符合条件的「破械」卡加入手卡，并向对方展示。
function c27412542.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家弹出选择提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从当前玩家的卡组中选择1张满足filter条件（「破械」系列且可加入手卡）的卡。
	local g=Duel.SelectMatchingCard(tp,c27412542.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果原因送去其持有者的手卡，即完成“加入手卡”的处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：这张卡被效果破坏，且破坏前位于场上并且是里侧表示（盖放状态）时才满足。
function c27412542.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 定义特殊召唤用的过滤器：卡必须属于「破械」系列字段，并且可以被当前玩家以通常规则特殊召唤（检查召唤条件和苏生限制）。
function c27412542.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件和操作信息设定函数：在发动时确认己方主要怪兽区有空位且卡组存在可特殊召唤的「破械」怪兽，并标记本次处理为特殊召唤。
function c27412542.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时点判定：己方主要怪兽区域是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动时点判定：卡组是否存在至少1只符合spfilter条件（「破械」系列且可特殊召唤）的怪兽；与15的条件同时满足时②才能发动。
		and Duel.IsExistingMatchingCard(c27412542.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设定操作信息：将本次效果处理登记为从卡组特殊召唤1只怪兽，来源是当前玩家的卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：在己方主要怪兽区仍有空位时，从卡组选择1只符合条件的「破械」怪兽，以表侧表示特殊召唤到己方场上。
function c27412542.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查己方主要怪兽区域是否有空位，若无空位则直接终止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家弹出选择提示，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从当前玩家的卡组中选择1只满足spfilter条件（「破械」系列且可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c27412542.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击/守备表示（POS_FACEUP）特殊召唤到当前玩家场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
