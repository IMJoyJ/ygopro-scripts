--驚楽園の助手 ＜Delia＞
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1张「游乐设施」陷阱卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：从手卡以及自己场上的表侧表示的卡之中把1张「游乐设施」陷阱卡送去墓地才能发动。从卡组选1张「游乐设施」陷阱卡在自己的魔法与陷阱区域盖放。
function c22662014.initial_effect(c)
	-- ①：把手卡1张「游乐设施」陷阱卡给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22662014,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,22662014)
	e1:SetCost(c22662014.spcost)
	e1:SetTarget(c22662014.sptg)
	e1:SetOperation(c22662014.spop)
	c:RegisterEffect(e1)
	-- ②：从手卡以及自己场上的表侧表示的卡之中把1张「游乐设施」陷阱卡送去墓地才能发动。从卡组选1张「游乐设施」陷阱卡在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22662014,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,22662015)
	e2:SetCost(c22662014.setcost)
	e2:SetTarget(c22662014.settg)
	e2:SetOperation(c22662014.setop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在1张未公开的「游乐设施」陷阱卡。
function c22662014.cfilter(c)
	return c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and not c:IsPublic()
end
-- 效果处理函数，检查手卡中是否存在满足条件的「游乐设施」陷阱卡，若存在则提示对方确认该卡并洗切手牌。
function c22662014.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张满足条件的「游乐设施」陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c22662014.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的1张「游乐设施」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c22662014.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的卡。
	Duel.ConfirmCards(1-tp,g)
	-- 将玩家的手牌洗切。
	Duel.ShuffleHand(tp)
end
-- 效果处理函数，检查是否满足特殊召唤条件。
function c22662014.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将此卡特殊召唤到场上。
function c22662014.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以正面表示形式特殊召唤到玩家场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于判断手卡或场上的「游乐设施」陷阱卡是否可以作为发动代价送去墓地。
function c22662014.costfilter(c,ft)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_TRAP) and c:IsSetCard(0x15c) and c:IsAbleToGraveAsCost()
		and (ft>0 or c:IsLocation(LOCATION_SZONE) and ft>-1)
end
-- 效果处理函数，检查场上或手卡中是否存在满足条件的「游乐设施」陷阱卡，若存在则选择并将其送去墓地。
function c22662014.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家魔法与陷阱区域的可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 检查玩家手卡或场上的「游乐设施」陷阱卡中是否存在至少1张可以作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c22662014.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,ft) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张「游乐设施」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c22662014.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,ft)
	-- 将所选的卡以代价形式送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，用于判断卡组中是否存在可以盖放的「游乐设施」陷阱卡。
function c22662014.setfilter(c,chk)
	return c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:IsSSetable(chk)
end
-- 效果处理函数，检查卡组中是否存在满足条件的「游乐设施」陷阱卡。
function c22662014.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以盖放的「游乐设施」陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c22662014.setfilter,tp,LOCATION_DECK,0,1,nil,true) end
end
-- 效果处理函数，从卡组中选择1张「游乐设施」陷阱卡并盖放到玩家场上。
function c22662014.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择1张满足条件的「游乐设施」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c22662014.setfilter,tp,LOCATION_DECK,0,1,1,nil,false)
	if g:GetCount()>0 then
		-- 将所选的卡盖放到玩家场上。
		Duel.SSet(tp,g:GetFirst())
	end
end
