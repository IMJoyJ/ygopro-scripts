--ドラゴンメイド・ティルル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「半龙女仆·蒸馏室龙女」以外的1只「半龙女仆」怪兽加入手卡。那之后，从手卡选1只「半龙女仆」怪兽送去墓地。
-- ②：自己·对方的战斗阶段开始时才能发动。这张卡回到手卡，从自己的手卡·墓地把1只8星「半龙女仆」怪兽特殊召唤。
function c16960120.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16960120,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,16960120)
	e1:SetTarget(c16960120.thtg)
	e1:SetOperation(c16960120.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己·对方的战斗阶段开始时才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16960120,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,16960121)
	e3:SetTarget(c16960120.sptg)
	e3:SetOperation(c16960120.spop)
	c:RegisterEffect(e3)
end
-- 检索条件：卡名属于半龙女仆系列且为怪兽卡且不是自身且可以加入手牌
function c16960120.thfilter(c)
	return c:IsSetCard(0x133) and c:IsType(TYPE_MONSTER) and not c:IsCode(16960120) and c:IsAbleToHand()
end
-- 效果发动时的处理：检查是否满足检索条件
function c16960120.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c16960120.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
end
-- 丢弃手牌的过滤条件：卡名属于半龙女仆系列且为怪兽卡
function c16960120.disfilter(c)
	return c:IsSetCard(0x133) and c:IsType(TYPE_MONSTER)
end
-- 效果处理：选择1张卡加入手牌并确认、洗牌、中断效果、丢弃1张手牌
function c16960120.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c16960120.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 将选中的卡加入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方确认加入手牌的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	-- 中断当前效果处理
	Duel.BreakEffect()
	-- 丢弃1张手牌
	Duel.DiscardHand(tp,c16960120.disfilter,1,1,REASON_EFFECT)
end
-- 特殊召唤的过滤条件：卡名属于半龙女仆系列且等级为8且可以特殊召唤
function c16960120.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理：检查是否满足特殊召唤条件
function c16960120.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 检查场上是否有可用怪兽区
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查手牌或墓地是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(c16960120.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：将自身送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：将自身送回手牌并选择1只怪兽特殊召唤
function c16960120.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否有效且成功送回手牌
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 检查自身是否在手牌且场上是否有可用怪兽区
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示选择：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16960120.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
