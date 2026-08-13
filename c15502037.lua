--電磁石の戦士γ
-- 效果：
-- 「电磁石战士γ」的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把「电磁石战士γ」以外的1只4星以下的「磁石战士」怪兽特殊召唤。
-- ②：对方回合把这张卡解放才能发动。从卡组把1只4星「磁石战士」怪兽特殊召唤。
function c15502037.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把「电磁石战士γ」以外的1只4星以下的「磁石战士」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15502037,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,15502037)
	e1:SetTarget(c15502037.target)
	e1:SetOperation(c15502037.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方回合把这张卡解放才能发动。从卡组把1只4星「磁石战士」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15502037,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCondition(c15502037.spcon)
	e3:SetCost(c15502037.spcost)
	e3:SetTarget(c15502037.sptg)
	e3:SetOperation(c15502037.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：从手牌中选出「磁石战士」系列、不是「电磁石战士γ」自身、等级4以下且可以被特殊召唤的怪兽，作为①效果特殊召唤的对象。
function c15502037.filter(c,e,tp)
	return c:IsSetCard(0x2066) and not c:IsCode(15502037) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动判定与目标设置：检查自己场上是否有怪兽区空位，且手牌存在符合过滤条件的「磁石战士」怪兽，满足则效果可以发动。
function c15502037.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足c15502037.filter条件的「磁石战士」怪兽。
		and Duel.IsExistingMatchingCard(c15502037.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：声明本效果将进行1只怪兽从手卡的特殊召唤，供相关卡片进行响应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：若自己场上仍有怪兽区空位，则从手牌选择1只符合条件的「磁石战士」怪兽，以表侧表示特殊召唤到自己场上。
function c15502037.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则不进行特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足c15502037.filter条件的「磁石战士」怪兽。
	local g=Duel.SelectMatchingCard(tp,c15502037.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件判定：当前回合玩家不是自己的控制者，即只能在对方回合发动。
function c15502037.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是自己（tp），满足“对方回合”这一条件。
	return Duel.GetTurnPlayer()~=tp
end
-- ②效果的发动代价：解放这张卡；在check阶段确认这张卡是否可以被解放。
function c15502037.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以解放为代价将这张卡送去墓地，作为发动②效果的COST。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：从卡组中选出「磁石战士」系列、等级4且可以被特殊召唤的怪兽，作为②效果从卡组特殊召唤的对象。
function c15502037.spfilter(c,e,tp)
	return c:IsSetCard(0x2066) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动判定与目标设置：检查自己场上是否预留有可特殊召唤的位置，且卡组存在满足条件的「磁石战士」怪兽。
function c15502037.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用于特殊召唤的怪兽区域（此处通过>-1判定发动时允许因解放自身腾出空位，处理时再确认具体空位）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在至少1只满足c15502037.spfilter条件的「磁石战士」怪兽。
		and Duel.IsExistingMatchingCard(c15502037.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：声明本效果将进行1只怪兽从卡组的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若自己场上有可用的怪兽区域，则从卡组选择1只符合条件的「磁石战士」怪兽，以表侧表示特殊召唤到自己场上。
function c15502037.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则不进行特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只满足c15502037.spfilter条件的「磁石战士」怪兽。
		local g=Duel.SelectMatchingCard(tp,c15502037.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上（不检查召唤条件与苏生限制）。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
