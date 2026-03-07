--ビットルーパー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：从手卡把1只2星以下的怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
function c36694815.initial_effect(c)
	-- 效果原文内容：这个卡名的效果1回合只能使用1次。
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
-- 效果作用：检查手卡中是否存在等级2以下且可以作为cost送去墓地的怪兽
function c36694815.cfilter(c)
	return c:IsLevelBelow(2) and c:IsAbleToGraveAsCost()
end
-- 效果作用：发动时选择1只手卡中满足条件的怪兽送去墓地作为cost
function c36694815.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果作用：判断是否满足发动条件，即手卡中存在1只2星以下的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c36694815.cfilter,tp,LOCATION_HAND,0,1,c) end
	-- 效果作用：向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 效果作用：选择1只手卡中满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c36694815.cfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 效果作用：将选中的怪兽送去墓地作为cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果作用：设定特殊召唤的发动条件
function c36694815.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果作用：判断场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 效果作用：设置连锁操作信息，表明将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果作用：处理特殊召唤效果
function c36694815.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 效果作用：将此卡从手卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
