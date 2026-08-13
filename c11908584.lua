--守護竜の核醒
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡把1只效果怪兽送去墓地才能发动。从自己的手卡·卡组·墓地选1只4星以下的龙族通常怪兽守备表示特殊召唤。
function c11908584.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：从手卡把1只效果怪兽送去墓地才能发动。从自己的手卡·卡组·墓地选1只4星以下的龙族通常怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11908584,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,11908584)
	e2:SetCost(c11908584.spcost)
	e2:SetTarget(c11908584.sptg)
	e2:SetOperation(c11908584.spop)
	c:RegisterEffect(e2)
end
-- 定义代价筛选：手卡中的卡必须是效果怪兽，并且可以作为代价送去墓地。
function c11908584.costfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsAbleToGraveAsCost()
end
-- 该效果的代价函数：在合法性检查时确认手卡存在可丢弃的效果怪兽，实际发动时从手卡丢弃1只效果怪兽作为代价。
function c11908584.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：判断手卡中是否存在至少1张满足costfilter条件（效果怪兽且可作为代价）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c11908584.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从手卡中选择1张满足costfilter条件的卡丢弃，丢弃原因设为REASON_COST。
	Duel.DiscardHand(tp,c11908584.costfilter,1,1,REASON_COST)
end
-- 定义特殊召唤对象筛选条件：必须是4星以下的龙族通常怪兽，且能够以表侧守备表示被当前效果特殊召唤。
function c11908584.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 目标检查阶段：确认自己主要怪兽区有空位，且手卡·卡组·墓地中存在至少1只符合条件的龙族通常怪兽。
function c11908584.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否至少有1个可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地中是否存在至少1只满足spfilter条件的龙族通常怪兽。
		and Duel.IsExistingMatchingCard(c11908584.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：本次效果处理将进行特殊召唤，处理范围是手卡·卡组·墓地，预计数量为1，以配合其他效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理阶段：若效果正常关联且场上仍有空位，则从手卡·卡组·墓地中选择1只符合条件的龙族通常怪兽，以表侧守备表示特殊召唤。
function c11908584.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理前检查：如果发动效果的卡已不关联本效果（如已离场），或自己场上没有可用的主要怪兽区，则效果不处理。
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡·卡组·墓地中选择1只满足spfilter条件、且不受王家长眠之谷影响的龙族通常怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11908584.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
