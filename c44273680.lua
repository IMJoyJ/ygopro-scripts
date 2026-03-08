--光天使ブックス
-- 效果：
-- 1回合1次，把手卡1张魔法卡送去墓地才能发动。从手卡把1只名字带有「光天使」的怪兽特殊召唤。
function c44273680.initial_effect(c)
	-- 效果原文：1回合1次，把手卡1张魔法卡送去墓地才能发动。从手卡把1只名字带有「光天使」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44273680,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c44273680.spcost)
	e1:SetTarget(c44273680.sptg)
	e1:SetOperation(c44273680.spop)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤手卡中可以作为cost送去墓地的魔法卡
function c44273680.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 效果作用：检查是否满足cost条件并丢弃1张手卡中的魔法卡
function c44273680.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查手卡中是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c44273680.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 效果作用：丢弃1张手卡中的魔法卡作为cost
	Duel.DiscardHand(tp,c44273680.cfilter,1,1,REASON_COST)
end
-- 效果作用：过滤手卡中名字带有「光天使」的怪兽
function c44273680.spfilter(c,e,tp)
	return c:IsSetCard(0x86) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：检查是否满足特殊召唤条件
function c44273680.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查手卡中是否存在满足条件的光天使怪兽
		and Duel.IsExistingMatchingCard(c44273680.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息，确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果作用：处理特殊召唤效果
function c44273680.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择1只满足条件的光天使怪兽
	local g=Duel.SelectMatchingCard(tp,c44273680.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
