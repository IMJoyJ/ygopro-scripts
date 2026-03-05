--ミニマリアン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从手卡把1张其他卡除外才能发动。这张卡特殊召唤。
-- ②：把自己场上1只4星以下的表侧表示怪兽除外才能发动。原本等级比除外的怪兽低1星或2星并原本的种族·属性相同的1只怪兽从卡组特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果，①效果在手卡发动，②效果在场上发动
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，从手卡把1张其他卡除外才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只4星以下的表侧表示怪兽除外才能发动。原本等级比除外的怪兽低1星或2星并原本的种族·属性相同的1只怪兽从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 定义除外卡的过滤函数，检查卡是否能作为除外的代价
function s.costfilter(c)
	return c:IsAbleToRemoveAsCost()
end
-- ①效果的除外代价处理，选择1张手卡除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足①效果的除外代价条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张手卡作为除外代价
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选中的卡除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的特殊召唤目标判定，检查是否能特殊召唤此卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，告知对方此卡将被特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的特殊召唤处理，将此卡特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的除外代价处理，设置标签用于判断是否已选择除外卡
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 定义②效果除外卡的过滤函数，检查是否满足除外条件
function s.costfilter2(c,e,tp)
	return c:IsFaceup() and c:GetOriginalLevel()>0 and c:IsLevelBelow(4)
		-- 检查场上是否有足够的怪兽区域用于除外
		and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToRemoveAsCost()
		-- 检查卡组中是否存在满足条件的怪兽用于特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,c,e,tp)
end
-- 定义特殊召唤目标的过滤函数，检查等级、种族、属性是否匹配
function s.spfilter(c,tc,e,tp)
	return (c:GetOriginalLevel()==tc:GetOriginalLevel()-1
		or c:GetOriginalLevel()==tc:GetOriginalLevel()-2)
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and c:GetOriginalAttribute()==tc:GetOriginalAttribute()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标选择与处理，选择除外卡并检索满足条件的怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在满足条件的怪兽用于除外
		return Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只怪兽作为除外代价
	local g=Duel.SelectMatchingCard(tp,s.costfilter2,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选中的怪兽除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 设置当前处理的连锁对象为除外的怪兽
	Duel.SetTargetCard(g)
	-- 设置效果处理信息，告知对方将从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的特殊召唤处理，从卡组特殊召唤符合条件的怪兽
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前处理的连锁对象（即除外的怪兽）
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择满足条件的1只怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,tc,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
