--グリッド・スィーパー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场地魔法卡表侧表示存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把墓地的这张卡以及自己场上1只连接怪兽除外才能发动。选对方场上1张卡破坏。
function c13090893.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：场地魔法卡表侧表示存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13090893,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,13090893)
	e1:SetCondition(c13090893.spcon)
	e1:SetTarget(c13090893.sptg)
	e1:SetOperation(c13090893.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：把墓地的这张卡以及自己场上1只连接怪兽除外才能发动。选对方场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13090893,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,13090894)
	e2:SetCost(c13090893.descost)
	e2:SetTarget(c13090893.destg)
	e2:SetOperation(c13090893.desop)
	c:RegisterEffect(e2)
end
-- ①效果的特殊召唤条件函数：检测双方场地魔法区域是否存在表侧表示的场地魔法卡，存在则满足发动条件。
function c13090893.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场地魔法区域合计是否存在至少1张表侧表示的场地魔法卡。
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- ①效果发动时的目标合法性检查函数：确认自己主要怪兽区有空位，且手卡的这张卡可以被特殊召唤。
function c13090893.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区域是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果操作信息：本次效果处理将把这张卡特殊召唤（类别为特殊召唤，对象为这张卡，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理时的操作函数：若这张卡仍与效果相关，则将它以表侧表示特殊召唤到自己场上。
function c13090893.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上（正常进行特殊召唤，不忽略召唤条件和苏生限制）。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果代价的筛选条件：选择自己场上的连接怪兽，且该怪兽可以作为代价被除外。
function c13090893.cfilter(c)
	return c:IsType(TYPE_LINK) and c:IsAbleToRemoveAsCost()
end
-- ②效果发动代价的合法性检查函数：确认墓地的这张卡和自己场上1只连接怪兽都能作为代价被除外。
function c13090893.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自己场上是否存在至少1只可作为代价除外的连接怪兽。
		and Duel.IsExistingMatchingCard(c13090893.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，要求玩家选择要除外的卡片（提示类型为“请选择要除外的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1只符合条件的连接怪兽作为除外代价的候选。
	local g=Duel.SelectMatchingCard(tp,c13090893.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 将墓地的这张卡和选择的连接怪兽一并除外，作为②效果发动的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标检查/操作信息登记函数：确认对方场上有卡，并将对方场上所有卡登记为可能被破坏的对象（不取对象，处理时选1张）。
function c13090893.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认对方场上有至少1张卡存在，否则②效果无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡，作为可能被破坏的候选集合。
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果操作信息：类别为破坏，候选集合为对方场上所有卡，预计破坏数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理时的操作函数：由玩家选择对方场上1张卡并破坏（不取对象）。
function c13090893.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要破坏的卡片（提示类型为“请选择要破坏的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张要破坏的卡。
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 展示被选择卡的选中动画，并记录其为该效果的对象。
		Duel.HintSelection(g)
		-- 将选择的卡以效果破坏送入墓地。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
