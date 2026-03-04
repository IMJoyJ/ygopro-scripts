--Kozmo－シーミウズ
-- 效果：
-- 「星际仙踪-飞猴队」的①的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从手卡把1只4星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
-- ②：1回合1次，支付1000基本分，以自己墓地1只念动力族「星际仙踪」怪兽为对象才能发动。那只怪兽特殊召唤。
function c1274455.initial_effect(c)
	-- ①：把场上的这张卡除外才能发动。从手卡把1只4星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1274455,0))  --"从手卡把「星际仙踪」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,1274455)
	e1:SetCost(c1274455.spcost)
	e1:SetTarget(c1274455.sptg)
	e1:SetOperation(c1274455.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，支付1000基本分，以自己墓地1只念动力族「星际仙踪」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1274455,1))  --"从墓地把「星际仙踪」怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c1274455.cost)
	e2:SetTarget(c1274455.target)
	e2:SetOperation(c1274455.operation)
	c:RegisterEffect(e2)
end
-- 效果处理时检查是否满足除外条件并执行除外操作
function c1274455.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身从场上除外作为发动代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 用于筛选满足条件的手卡怪兽
function c1274455.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelAbove(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动条件和目标选择
function c1274455.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否有满足条件的怪兽且场上存在召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 确认手卡中存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c1274455.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，执行特殊召唤操作
function c1274455.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从手卡中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c1274455.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 支付LP的处理函数
function c1274455.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 用于筛选满足条件的墓地怪兽
function c1274455.filter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动条件和目标选择
function c1274455.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c1274455.filter(chkc,e,tp) end
	-- 检查墓地中是否有满足条件的怪兽且场上存在召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认墓地中存在满足条件的怪兽
		and Duel.IsExistingTarget(c1274455.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从墓地中选择满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c1274455.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，执行特殊召唤操作
function c1274455.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
