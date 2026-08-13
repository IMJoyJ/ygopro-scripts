--Kozmo－ダーク・エルファイバー
-- 效果：
-- 「星际仙踪-达克·艾伐芭」的①的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从手卡把1只6星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
-- ②：1回合1次，这张卡以外的怪兽的效果发动时，支付1000基本分才能发动。那个发动无效并破坏。
function c12408276.initial_effect(c)
	-- 「星际仙踪-达克·艾伐芭」的①的效果1回合只能使用1次。①：把场上的这张卡除外才能发动。从手卡把1只6星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
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
-- ①效果的发动代价：先判断这张卡能否作为除外代价；若可以则将其从场上表侧表示除外。
function c12408276.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将这张卡自身从场上表侧表示除外，作为发动①效果的代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 特殊召唤的过滤条件：手牌中的「星际仙踪」怪兽，等级6以上，且能够被效果特殊召唤。
function c12408276.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelAbove(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标检查：在发动时判断主怪兽区是否有空位（用>-1宽松判断，因除外自身后可腾出格子）以及手牌是否存在满足条件的「星际仙踪」怪兽，两者均满足才可发动。
function c12408276.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有空位（用>-1宽松判断，因为发动代价会除外自身，当前无空格也可能除外后有空位）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 同时确认手牌中存在满足特定条件的「星际仙踪」怪兽（6星以上且可特殊召唤），两者均满足时效果才可发动。
		and Duel.IsExistingMatchingCard(c12408276.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：本效果包含特殊召唤，预定从持有者手牌特殊召唤1只怪兽，具体对象在处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：若主怪兽区没有空位则直接结束；否则提示玩家选择1张手牌中符合条件的「星际仙踪」怪兽，将其表侧表示特殊召唤到自己场上。
function c12408276.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主怪兽区有空位；若没有空位，则本次特殊召唤不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，提示内容为‘请选择要特殊召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1张满足 spfilter 的「星际仙踪」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c12408276.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到操作者场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡不是战斗破坏确定状态，发动效果的是其他怪兽（不是这张卡自身），且该效果为怪兽效果，并且该连锁可以被无效。
function c12408276.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:GetHandler()~=e:GetHandler()
		-- 进一步确认那是怪兽效果的发动（不是魔法陷阱），且当前连锁可以被无效。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- ②效果的代价处理：先检查能否支付1000基本分；若可以，实际支付1000基本分作为发动代价。
function c12408276.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认玩家拥有至少1000基本分可以支付。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分作为发动②效果的代价。
	Duel.PayLPCost(tp,1000)
end
-- ②效果的目标检查：发动时无需选择对象；登记要将当前连锁的发动无效，并登记如果对象怪兽可被破坏则一并破坏。
function c12408276.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次效果包含‘使发动无效’，对象为当前连锁中的卡（eg）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记操作信息：若被无效的怪兽可被破坏且仍与效果相关，则本次效果也包含破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：先无效该怪兽效果的发动；若无效成功且那只怪兽仍与效果相关，则将其破坏。
function c12408276.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行发动无效；仅当无效成功且该怪兽仍与效果相关时，才继续后续的破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果破坏被无效发动的怪兽。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
