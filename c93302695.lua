--Kozmo－ダーク・ローズ
-- 效果：
-- 「星际仙踪-达克·萝丝」的①的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从手卡把1只5星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
-- ②：1回合1次，支付1000基本分才能发动。这个回合，这张卡不会被战斗·效果破坏。这个效果在对方回合也能发动。
function c93302695.initial_effect(c)
	-- 「星际仙踪-达克·萝丝」的①的效果1回合只能使用1次。①：把场上的这张卡除外才能发动。从手卡把1只5星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93302695,0))  --"从手卡把「星际仙踪」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,93302695)
	e1:SetCost(c93302695.spcost)
	e1:SetTarget(c93302695.sptg)
	e1:SetOperation(c93302695.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，支付1000基本分才能发动。这个回合，这张卡不会被战斗·效果破坏。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93302695,1))  --"这张卡不会被战斗·效果破坏"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c93302695.indcost)
	e2:SetOperation(c93302695.indop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：检查自身是否能除外，并将自身除外。
function c93302695.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身作为代价表侧表示除外。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤条件：手卡中5星以上的「星际仙踪」怪兽。
function c93302695.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备：检查怪兽区域是否有空位，以及手卡中是否存在满足条件的怪兽，并设置特殊召唤的操作信息。
function c93302695.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（因为自身作为代价除外会空出一个格子，所以可用格子数大于-1即可）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡中是否存在至少1只满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c93302695.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡特殊召唤1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的效果处理：从手卡选择1只5星以上的「星际仙踪」怪兽特殊召唤。
function c93302695.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则返回。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择手卡中1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c93302695.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动代价：检查并支付1000基本分。
function c93302695.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分。
	Duel.PayLPCost(tp,1000)
end
-- ②效果的效果处理：给这张卡添加“这个回合不会被战斗·效果破坏”的抗性。
function c93302695.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡不会被效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		c:RegisterEffect(e2)
	end
end
