--電磁石の戦士α
-- 效果：
-- 「电磁石战士α」的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只8星「磁石战士」怪兽加入手卡。
-- ②：对方回合把这张卡解放才能发动。从卡组把1只4星「磁石战士」怪兽特殊召唤。
function c42023223.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只8星「磁石战士」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42023223,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,42023223)
	e1:SetTarget(c42023223.thtg)
	e1:SetOperation(c42023223.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方回合把这张卡解放才能发动。从卡组把1只4星「磁石战士」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42023223,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCondition(c42023223.spcon)
	e3:SetCost(c42023223.spcost)
	e3:SetTarget(c42023223.sptg)
	e3:SetOperation(c42023223.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选卡组中满足条件的8星「磁石战士」怪兽（可加入手牌）
function c42023223.thfilter(c)
	return c:IsSetCard(0xe9) and c:IsLevel(8) and c:IsAbleToHand()
end
-- 设置效果处理时的连锁操作信息，确定将从卡组检索1只8星「磁石战士」怪兽加入手牌
function c42023223.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的8星「磁石战士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c42023223.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的连锁操作信息，确定将从卡组检索1只8星「磁石战士」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动后的操作，选择并把符合条件的怪兽加入手牌，并向对手确认其存在
function c42023223.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的8星「磁石战士」怪兽
	local g=Duel.SelectMatchingCard(tp,c42023223.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手确认其手牌中被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否为对方回合，用于触发效果②
function c42023223.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为非发动者，用于触发效果②
	return Duel.GetTurnPlayer()~=tp
end
-- 设置效果发动的代价，需要解放自身
function c42023223.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价原因解放自身
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选卡组中满足条件的4星「磁石战士」怪兽（可特殊召唤）
function c42023223.spfilter(c,e,tp)
	return c:IsSetCard(0x2066) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时的连锁操作信息，确定将从卡组检索1只4星「磁石战士」怪兽特殊召唤
function c42023223.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在至少1张满足条件的4星「磁石战士」怪兽
		and Duel.IsExistingMatchingCard(c42023223.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时的连锁操作信息，确定将从卡组检索1只4星「磁石战士」怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动后的操作，选择并把符合条件的怪兽特殊召唤到场上
function c42023223.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1张满足条件的4星「磁石战士」怪兽
		local g=Duel.SelectMatchingCard(tp,c42023223.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以特殊召唤方式召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
