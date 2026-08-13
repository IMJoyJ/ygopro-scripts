--光天使ブックス
-- 效果：
-- 1回合1次，把手卡1张魔法卡送去墓地才能发动。从手卡把1只名字带有「光天使」的怪兽特殊召唤。
function c44273680.initial_effect(c)
	-- 1回合1次，把手卡1张魔法卡送去墓地才能发动。从手卡把1只名字带有「光天使」的怪兽特殊召唤。
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
-- 筛选可作为代价送去墓地的手卡魔法卡：必须是魔法卡，并且可以作为代价送去墓地。
function c44273680.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 代价处理函数：先检查是否满足代价条件，满足则执行丢弃手卡中1张符合条件的魔法卡作为发动代价。
function c44273680.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查阶段，确认手卡中是否存在1张满足条件的魔法卡可用于代价，以判断效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c44273680.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡丢弃1张满足条件的魔法卡，作为发动效果的代价。
	Duel.DiscardHand(tp,c44273680.cfilter,1,1,REASON_COST)
end
-- 筛选可特殊召唤的「光天使」怪兽：必须是名字带有「光天使」的怪兽，且可以被玩家tp用此效果特殊召唤。
function c44273680.spfilter(c,e,tp)
	return c:IsSetCard(0x86) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标判断：检查自己场上是否有空余的主要怪兽区，以及手卡中是否存在可以特殊召唤的「光天使」怪兽，并设置特殊召唤的操作信息。
function c44273680.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上主要怪兽区存在空位，否则无法进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手卡中存在至少1只满足特殊召唤条件且名字带有「光天使」的怪兽。
		and Duel.IsExistingMatchingCard(c44273680.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息，声明本效果将进行特殊召唤，对象从手卡中处理，数量预计为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理阶段：若场上仍有空位，则让玩家从手卡选择1只名字带有「光天使」的怪兽，以表侧表示特殊召唤到自己场上。
function c44273680.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区仍有空位，若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择提示消息，要求从手卡中选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1张满足条件（名字带有「光天使」且可被特殊召唤）的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c44273680.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的那只怪兽以表侧攻击表示特殊召唤到发动者场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
