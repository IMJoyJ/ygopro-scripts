--ビットルーパー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：从手卡把1只2星以下的怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
function c36694815.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：从手卡把1只2星以下的怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,36694815)
	e1:SetCost(c36694815.spcost)
	e1:SetTarget(c36694815.sptg)
	e1:SetOperation(c36694815.spop)
	c:RegisterEffect(e1)
end
-- 定义代价过滤函数：检查手卡中是否存在等级2以下且可以作为代价送去墓地的怪兽。
function c36694815.cfilter(c)
	return c:IsLevelBelow(2) and c:IsAbleToGraveAsCost()
end
-- 代价函数：支付时从手卡选择1只等级2以下的怪兽送去墓地作为发动代价。
function c36694815.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检查阶段：判断手卡中是否存在至少1只满足过滤条件且不是自身的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c36694815.cfilter,tp,LOCATION_HAND,0,1,c) end
	-- 向玩家发送选择提示消息，提示需要选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1只符合过滤条件的怪兽作为代价（不包括自身）。
	local g=Duel.SelectMatchingCard(tp,c36694815.cfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 将选择的怪兽送去墓地，作为发动效果的代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标函数：检查这张卡是否能够特殊召唤，以及自己场上是否有特殊召唤所需的空位。
function c36694815.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，标明将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数：在效果处理时确认卡片仍与效果关联，若关联则执行特殊召唤。
function c36694815.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以表侧攻击表示将这张卡从手卡特殊召唤到自己的场上（不进行召唤条件/苏生限制的检查）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
