--Kozmo－ダーク・エルファイバー
-- 效果：
-- 「星际仙踪-达克·艾伐芭」的①的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从手卡把1只6星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
-- ②：1回合1次，这张卡以外的怪兽的效果发动时，支付1000基本分才能发动。那个发动无效并破坏。
function c12408276.initial_effect(c)
	-- ①：把场上的这张卡除外才能发动。从手卡把1只6星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12408276,0))  --"从手卡把「星际仙踪」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,12408276)
	e1:SetCost(c12408276.spcost)
	e1:SetTarget(c12408276.sptg)
	e1:SetOperation(c12408276.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡以外的怪兽的效果发动时，支付1000基本分才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12408276,1))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1)
	e2:SetCondition(c12408276.negcon)
	e2:SetCost(c12408276.negcost)
	e2:SetTarget(c12408276.negtg)
	e2:SetOperation(c12408276.negop)
	c:RegisterEffect(e2)
end
-- 设置效果发动时的费用处理，将自身除外作为费用
function c12408276.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身从场上除外，作为特殊召唤效果的费用
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 定义特殊召唤时的过滤条件，用于筛选手卡中满足条件的「星际仙踪」怪兽
function c12408276.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelAbove(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择处理
function c12408276.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的条件，包括场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡中是否存在满足条件的「星际仙踪」怪兽
		and Duel.IsExistingMatchingCard(c12408276.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息，告知对方将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 设置特殊召唤效果的处理函数
function c12408276.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从手卡中选择满足条件的「星际仙踪」怪兽
	local g=Duel.SelectMatchingCard(tp,c12408276.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置无效效果发动的触发条件
function c12408276.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:GetHandler()~=e:GetHandler()
		-- 检查连锁是否可以被无效，且发动的卡为怪兽卡
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 设置无效效果发动时的费用处理，支付1000基本分
function c12408276.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分作为费用
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分作为无效效果发动的费用
	Duel.PayLPCost(tp,1000)
end
-- 设置无效效果发动的目标处理
function c12408276.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效效果的操作信息，告知对方将要使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏效果的操作信息，告知对方将要破坏发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 设置无效效果发动的处理函数
function c12408276.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效，并判断是否可以破坏发动的卡
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效的连锁所对应的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
