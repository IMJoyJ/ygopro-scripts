--古代遺跡の目覚め
-- 效果：
-- ①：1回合1次，可以从自己墓地把岩石族怪兽或者场地魔法卡合计2张除外，从以下效果选择1个发动。
-- ●以这张卡以外的场上1张表侧表示的卡为对象才能发动。那张卡破坏。
-- ●以自己墓地1只岩石族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ●以自己墓地最多3张场地魔法卡为对象才能发动。那些卡加入卡组洗切。那之后，自己从卡组抽1张。
function c96100333.initial_effect(c)
	-- ①：1回合1次，可以从自己墓地把岩石族怪兽或者场地魔法卡合计2张除外，从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96100333,0))  --"选择1个效果发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ●以这张卡以外的场上1张表侧表示的卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96100333,1))  --"卡片破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(c96100333.descost)
	e2:SetTarget(c96100333.destg)
	e2:SetOperation(c96100333.desop)
	c:RegisterEffect(e2)
	-- ●以自己墓地1只岩石族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(96100333,2))  --"从墓地特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetTarget(c96100333.sptg)
	e3:SetOperation(c96100333.spop)
	c:RegisterEffect(e3)
	-- ●以自己墓地最多3张场地魔法卡为对象才能发动。那些卡加入卡组洗切。那之后，自己从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(96100333,3))  --"回收并抽卡"
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetTarget(c96100333.tdtg)
	e4:SetOperation(c96100333.tdop)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己墓地的岩石族怪兽或者场地魔法卡，且可以作为cost除外
function c96100333.cfilter(c)
	return (c:IsRace(RACE_ROCK) or c:IsType(TYPE_FIELD)) and c:IsAbleToRemoveAsCost()
end
-- 破坏效果的cost注册函数：检查并从自己墓地将合计2张岩石族怪兽或场地魔法卡除外
function c96100333.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少2张满足除外条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c96100333.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c96100333.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选择的卡作为发动成本（cost）表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：场上表侧表示的卡
function c96100333.desfilter(c)
	return c:IsFaceup()
end
-- 破坏效果的target注册函数：选择场上1张除这张卡以外的表侧表示卡片作为对象，并设置破坏操作信息
function c96100333.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c96100333.desfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查场上是否存在至少1张除这张卡以外的表侧表示卡片可以作为对象
	if chk==0 then return Duel.IsExistingTarget(c96100333.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1张除这张卡以外的场上表侧表示卡片作为效果对象
	local g=Duel.SelectTarget(tp,c96100333.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置当前连锁的操作信息为：破坏该目标卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的operation注册函数：将作为对象的卡片破坏
function c96100333.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 辅助过滤条件1：用于在特召效果发动时，检查除外2张cost后，墓地是否仍留有至少1只可特召的岩石族怪兽
function c96100333.spcfilter1(c,cg,sg)
	local g=sg:Clone()
	g:RemoveCard(c)
	return cg:IsExists(c96100333.spcfilter2,1,c,g)
end
-- 辅助过滤条件2：用于在特召效果发动时，检查除外第2张cost后，墓地是否仍留有至少1只可特召的岩石族怪兽
function c96100333.spcfilter2(c,sg)
	-- 检查特召候选卡片组中是否存在除当前卡以外的至少1张卡
	return sg:IsExists(aux.TRUE,1,c)
end
-- 过滤条件：自己墓地的岩石族怪兽，且可以守备表示特殊召唤
function c96100333.spfilter(c,e,tp)
	-- 检查卡片是否为岩石族怪兽，且能以守备表示特殊召唤（根据是否为特殊召唤怪兽决定是否忽略召唤条件）
	return c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.TriamidSpSummonType(c),POS_FACEUP_DEFENSE)
end
-- 特召效果的target注册函数：检查怪兽区域空位，选择并支付除外2张卡的cost，选择墓地1只岩石族怪兽作为对象，并设置特殊召唤操作信息
function c96100333.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c96100333.spfilter(chkc,e,tp) end
	-- 获取自己墓地中所有满足除外cost条件的卡片组
	local cg=Duel.GetMatchingGroup(c96100333.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取自己墓地中所有满足特殊召唤条件的岩石族怪兽卡片组
	local sg=Duel.GetMatchingGroup(c96100333.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and cg:IsExists(c96100333.spcfilter1,1,nil,cg,sg) end
	-- 提示玩家选择第1张要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g1=cg:FilterSelect(tp,c96100333.spcfilter1,1,1,nil,cg,sg)
	sg:RemoveCard(g1:GetFirst())
	-- 提示玩家选择第2张要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g2=cg:FilterSelect(tp,c96100333.spcfilter2,1,1,g1:GetFirst(),sg)
	sg:RemoveCard(g2:GetFirst())
	g1:Merge(g2)
	-- 将选择的2张卡作为发动成本（cost）表侧表示除外
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=sg:Select(tp,1,1,nil)
	-- 将选择的怪兽设置为当前效果的对象
	Duel.SetTargetCard(g)
	-- 设置当前连锁的操作信息为：特殊召唤该目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特召效果的operation注册函数：将作为对象的怪兽守备表示特殊召唤
function c96100333.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以守备表示特殊召唤，若特召成功且该怪兽是特殊召唤怪兽，则准备进行正规召唤程序
		if Duel.SpecialSummon(tc,0,tp,tp,false,aux.TriamidSpSummonType(tc),POS_FACEUP_DEFENSE)~=0 and aux.TriamidSpSummonType(tc) then
			tc:CompleteProcedure()
		end
	end
end
-- 辅助过滤条件1：用于在回收抽卡效果发动时，检查除外2张cost后，墓地是否仍留有至少1张可回收的场地魔法卡
function c96100333.tdcfilter1(c,cg,sg)
	local g=sg:Clone()
	g:RemoveCard(c)
	return cg:IsExists(c96100333.spcfilter2,1,c,g)
end
-- 辅助过滤条件2：用于在回收抽卡效果发动时，检查除外第2张cost后，墓地是否仍留有至少1张可回收的场地魔法卡
function c96100333.tdcfilter2(c,sg)
	-- 检查回收候选卡片组中是否存在除当前卡以外的至少1张卡
	return sg:IsExists(aux.TRUE,1,c)
end
-- 过滤条件：自己墓地的场地魔法卡，且可以返回卡组
function c96100333.tdfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToDeck()
end
-- 回收抽卡效果的target注册函数：检查是否能抽卡，选择并支付除外2张卡的cost，选择墓地最多3张场地魔法卡作为对象，并设置返回卡组和抽卡的操作信息
function c96100333.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c96100333.tdfilter(chkc) end
	-- 获取自己墓地中所有满足除外cost条件的卡片组
	local cg=Duel.GetMatchingGroup(c96100333.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取自己墓地中所有满足返回卡组条件的场地魔法卡片组
	local sg=Duel.GetMatchingGroup(c96100333.tdfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查自己当前是否可以进行效果抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and cg:IsExists(c96100333.tdcfilter1,1,nil,cg,sg) end
	-- 提示玩家选择第1张要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g1=cg:FilterSelect(tp,c96100333.tdcfilter1,1,1,nil,cg,sg)
	sg:RemoveCard(g1:GetFirst())
	-- 提示玩家选择第2张要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g2=cg:FilterSelect(tp,c96100333.tdcfilter2,1,1,g1:GetFirst(),sg)
	sg:RemoveCard(g2:GetFirst())
	g1:Merge(g2)
	-- 将选择的2张卡作为发动成本（cost）表侧表示除外
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
	-- 提示玩家选择要返回卡组的场地魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local g=sg:Select(tp,1,3,nil)
	-- 将选择的场地魔法卡设置为当前效果的对象
	Duel.SetTargetCard(g)
	-- 设置当前连锁的操作信息为：将选择的对象卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置当前连锁的操作信息为：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 回收抽卡效果的operation注册函数：将作为对象的场地魔法卡送回卡组洗切，之后自己从卡组抽1张卡
function c96100333.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果有关联的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()==0 then return end
	-- 因效果将这些卡送回持有者卡组并洗卡
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果有卡片被送回了卡组，则洗切自己的卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果处理，使后续的抽卡处理不与返回卡组视为同时进行
		Duel.BreakEffect()
		-- 因效果从自己卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
