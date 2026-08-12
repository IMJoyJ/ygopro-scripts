--電磁石の戦士β
-- 效果：
-- 「电磁石战士β」的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「电磁石战士β」以外的1只4星以下的「磁石战士」怪兽加入手卡。
-- ②：对方回合把这张卡解放才能发动。从卡组把1只4星「磁石战士」怪兽特殊召唤。
function c79418928.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「电磁石战士β」以外的1只4星以下的「磁石战士」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79418928,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,79418928)
	e1:SetTarget(c79418928.thtg)
	e1:SetOperation(c79418928.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方回合把这张卡解放才能发动。从卡组把1只4星「磁石战士」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79418928,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCondition(c79418928.spcon)
	e3:SetCost(c79418928.spcost)
	e3:SetTarget(c79418928.sptg)
	e3:SetOperation(c79418928.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组中「电磁石战士β」以外的4星以下的「磁石战士」怪兽
function c79418928.thfilter(c)
	return c:IsSetCard(0x2066) and not c:IsCode(79418928) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- ①效果的发动准备（检查卡组是否存在符合条件的怪兽，并设置操作信息）
function c79418928.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c79418928.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理（从卡组选择1只符合条件的怪兽加入手卡并给对方确认）
function c79418928.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c79418928.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件（对方回合）
function c79418928.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- ②效果的发动代价（解放自身）
function c79418928.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡组中可以特殊召唤的4星「磁石战士」怪兽
function c79418928.spfilter(c,e,tp)
	return c:IsSetCard(0x2066) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备（检查怪兽区域空位及卡组中是否存在符合条件的怪兽）
function c79418928.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查怪兽区域是否有空位（由于解放自身作为代价，空位数需大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并且检查卡组中是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c79418928.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理（从卡组选择1只符合条件的怪兽特殊召唤到场上）
function c79418928.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有可用的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组中选择1只满足过滤条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c79418928.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
