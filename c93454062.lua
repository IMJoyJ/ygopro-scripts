--ナチュル・モルクリケット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把这张卡解放才能发动。从卡组把1只「自然」怪兽特殊召唤。攻击力最高的怪兽在对方场上存在的场合，这个效果特殊召唤的数量可以变成2只。
-- ②：这张卡在墓地存在的状态，对方从额外卡组把怪兽特殊召唤的场合或者自己从额外卡组把「自然」怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
function c93454062.initial_effect(c)
	-- 注册一个监听送入墓地事件的单次持续效果，用于后续检测该卡是否在发动前就已存在于墓地
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：自己·对方的主要阶段，把这张卡解放才能发动。从卡组把1只「自然」怪兽特殊召唤。攻击力最高的怪兽在对方场上存在的场合，这个效果特殊召唤的数量可以变成2只。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93454062,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,93454062)
	e1:SetCondition(c93454062.spcon)
	e1:SetCost(c93454062.spcost)
	e1:SetTarget(c93454062.sptg)
	e1:SetOperation(c93454062.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，对方从额外卡组把怪兽特殊召唤的场合或者自己从额外卡组把「自然」怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93454062,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,93454063)
	e2:SetLabelObject(e0)
	e2:SetCondition(c93454062.rvcon)
	e2:SetTarget(c93454062.rvtg)
	e2:SetOperation(c93454062.rvop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自己或对方的主要阶段
function c93454062.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果①的发动代价：解放这张卡（或适用「自然春风」效果时从卡组将2张卡送去墓地）
function c93454062.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家是否受到「自然春风」效果的影响（可以用卡组送墓代替解放）
	local fe=Duel.IsPlayerAffectedByEffect(tp,29942771)
	-- 检查是否能适用「自然春风」的效果，将卡组最上方2张卡送去墓地作为代替代价，且己方场上有可用的怪兽区域
	local b1=fe and Duel.IsPlayerCanDiscardDeckAsCost(tp,2) and Duel.GetMZoneCount(tp)>0
	-- 检查这张卡是否可以被解放，且解放后己方场上有可用的怪兽区域
	local b2=c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0
	if chk==0 then return b1 or b2 end
	-- 如果可以适用「自然春风」的代替效果，且玩家选择适用该效果
	if b1 and (not b2 or Duel.SelectYesNo(tp,fe:GetDescription())) then
		-- 提示发动「自然春风」的代替效果
		Duel.Hint(HINT_CARD,0,29942771)
		fe:UseCountLimit(tp)
		-- 作为代替代价，将己方卡组最上方的2张卡送去墓地
		Duel.DiscardDeck(tp,2,REASON_COST)
	else
		-- 解放这张卡作为发动的代价
		Duel.Release(c,REASON_COST)
	end
end
-- 过滤条件：卡组中的「自然」怪兽，且可以被特殊召唤
function c93454062.spfilter(c,e,tp)
	return c:IsSetCard(0x2a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的靶向与合法性检测：检查卡组中是否存在可特殊召唤的「自然」怪兽，并设置特殊召唤的操作信息
function c93454062.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组中是否存在至少1只满足条件的「自然」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c93454062.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：根据场上怪兽的攻击力情况，从卡组特殊召唤1只或最多2只「自然」怪兽
function c93454062.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取双方场上所有表侧表示存在的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and tg and tg:IsExists(Card.IsControler,1,nil,1-tp) then
		ft=2
	else
		ft=1
	end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1到ft只满足条件的「自然」怪兽
	local sg=Duel.SelectMatchingCard(tp,c93454062.spfilter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if sg:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：对方从额外卡组特殊召唤的怪兽，或者己方从额外卡组特殊召唤的「自然」怪兽（排除由自身效果触发的特殊召唤）
function c93454062.cfilter(c,tp,se)
	return (c:IsSummonPlayer(1-tp) or c:IsSetCard(0x2a)) and c:IsSummonLocation(LOCATION_EXTRA)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 效果②的发动条件：检查是否有满足条件的怪兽从额外卡组特殊召唤
function c93454062.rvcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c93454062.cfilter,1,nil,tp,se)
end
-- 效果②的靶向与合法性检测：检查己方场上是否有空位，且这张卡是否能从墓地特殊召唤
function c93454062.rvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，将墓地的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将墓地的这张卡特殊召唤
function c93454062.rvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
