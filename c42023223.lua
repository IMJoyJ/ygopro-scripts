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
-- 该过滤器用于筛选卡组中满足条件的检索对象：等级为8、属于「磁石战士」字段（0xe9）、且可以被加入手卡的怪兽。
function c42023223.thfilter(c)
	return c:IsSetCard(0xe9) and c:IsLevel(8) and c:IsAbleToHand()
end
-- ①效果的发动条件和操作信息设定：当卡组存在符合条件的8星「磁石战士」怪兽时允许发动，并声明效果类别为“从卡组加入手卡”的检索效果。
function c42023223.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：确认卡组中存在至少1张满足thfilter过滤条件的检索对象。
	if chk==0 then return Duel.IsExistingMatchingCard(c42023223.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将本次效果处理标记为把1张卡从卡组加入手卡，供连锁判定与相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：由玩家从卡组选择1张符合条件的8星「磁石战士」怪兽加入手卡，并让对方确认加入手卡的卡。
function c42023223.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息“请选择要加入手牌的卡”，引导玩家选择检索对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足thfilter条件的卡（不取对象，在效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c42023223.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手卡的卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件函数：确认当前回合为对方回合，即自己不能在该回合发动（对方回合才能发动）。
function c42023223.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是效果控制者tp，即满足“对方回合”的发动条件。
	return Duel.GetTurnPlayer()~=tp
end
-- ②效果的代价函数：确认这张卡可以被解放，并将解放这张卡作为发动代价。
function c42023223.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 把这张卡解放，解放原因为代价（REASON_COST），即作为发动②效果所需支付的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 该过滤器用于筛选特殊召唤对象：等级为4、属于「磁石战士」字段（0x2066）、且可以被当前效果特殊召唤的怪兽。
function c42023223.spfilter(c,e,tp)
	return c:IsSetCard(0x2066) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件和操作信息设定：检查主要怪兽区可用空格（解放后会有空位）且卡组存在符合条件的4星「磁石战士」怪兽，并声明效果类别为特殊召唤。
function c42023223.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上主要怪兽区的可用空格数是否满足要求（此处用>-1，实际不因当前格子数限制发动，因为解放后会腾出格子）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 同时检查卡组中是否存在至少1只满足spfilter过滤条件的特殊召唤对象，以保证效果能够处理。
		and Duel.IsExistingMatchingCard(c42023223.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：将本次效果处理标记为从卡组特殊召唤1只怪兽，供相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实际处理：如果自己场上主要怪兽区有空位，则从卡组选择1只符合条件的4星「磁石战士」怪兽特殊召唤。
function c42023223.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时确认自己场上主要怪兽区仍有空格，确保特殊召唤能够进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示选择提示消息“请选择要特殊召唤的卡”，引导玩家选择特殊召唤对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只满足spfilter条件的怪兽（不取对象，在效果处理时选择）。
		local g=Duel.SelectMatchingCard(tp,c42023223.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
