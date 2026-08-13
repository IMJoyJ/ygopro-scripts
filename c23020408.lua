--魂のしもべ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从自己的手卡·卡组·墓地选除「魂之仆人」外的1只「黑魔术师」或「黑魔术少女」或者1张有那其中任意种的卡名记述的卡在卡组最上面放置。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。自己抽出双方的场上·墓地的「守护神官」怪兽、「黑魔术师」、「黑魔术少女」种类的数量。
function c23020408.initial_effect(c)
	-- 记录本卡（魂之仆人）效果文本中记述的卡号46986414（黑魔术师）和38033121（黑魔术少女），供aux.IsCodeOrListed判断相关卡名使用。
	aux.AddCodeList(c,46986414,38033121)
	-- ①：从自己的手卡·卡组·墓地选除「魂之仆人」外的1只「黑魔术师」或「黑魔术少女」或者1张有那其中任意种的卡名记述的卡在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23020408,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c23020408.target)
	e1:SetOperation(c23020408.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段把墓地的这张卡除外才能发动。自己抽出双方的场上·墓地的「守护神官」怪兽、「黑魔术师」、「黑魔术少女」种类的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23020408,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,23020408)
	-- 将②效果的发动代价设置为把墓地的这张卡除外（aux.bfgcost实现除外自身作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c23020408.drtg)
	e2:SetOperation(c23020408.drop)
	c:RegisterEffect(e2)
end
-- 定义①效果的可选卡过滤函数：卡名或效果文本相关于「黑魔术师」「黑魔术少女」、不是本卡、且能回卡组或已在卡组中。
function c23020408.filter(c)
	-- 过滤条件前半：卡为「黑魔术师」或「黑魔术少女」或效果文本中记述了其中任一卡名，且排除「魂之仆人」自身。
	return (aux.IsCodeOrListed(c,46986414) or aux.IsCodeOrListed(c,38033121)) and not c:IsCode(23020408)
		and (c:IsAbleToDeck() or c:IsLocation(LOCATION_DECK))
end
-- ①效果的发动合法检查和操作信息设置：若手卡·卡组·墓地存在符合条件的卡则可发动，并预设置将1张卡返回卡组的操作信息。
function c23020408.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：手卡·卡组·墓地中是否存在至少1张满足c23020408.filter的卡，存在才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c23020408.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息为：预定将1张卡从手卡或墓地返回卡组（卡组内的卡仅移动位置，不计入此操作）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果处理：选择1张符合条件的卡，洗切卡组后将其放置到卡组最上方；若来自卡组则移动顺序，否则以效果送回卡组顶端，并展示确认。
function c23020408.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示“请选择要放置在卡组最上面的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23020408,2))  --"请选择要放置在卡组最上面的卡"
	-- 让玩家从手卡·卡组·墓地选择1张符合条件的卡，并通过NecroValleyFilter排除受王家长眠之谷影响不能移动的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c23020408.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 洗切玩家tp的卡组。
		Duel.ShuffleDeck(tp)
		-- 为选中的卡显示被选择动画并记录其被选为对象（广义）。
		Duel.HintSelection(g)
		if tc:IsLocation(LOCATION_DECK) then
			-- 若选择的卡已在卡组中，将其移动到卡组最上方。
			Duel.MoveSequence(tc,SEQ_DECKTOP)
		else
			-- 若选择的卡在手卡或墓地，以效果原因将其送至持有者卡组最上方。
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
		if tc:IsLocation(LOCATION_DECK) then
			-- 确认并展示卡组最上方1张卡（即刚放置的卡）。
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
-- 定义②效果计数用过滤函数：筛选出表侧表示或位于墓地的「黑魔术师」「黑魔术少女」以及「守护神官」怪兽。
function c23020408.cfilter(c)
	return (c:IsCode(46986414,38033121) or (c:IsSetCard(0x139) and c:IsType(TYPE_MONSTER))) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- ②效果的发动条件与操作信息设置：统计双方场上·墓地符合条件的怪兽种类数，检查可抽数量，设置抽牌玩家、参数和操作信息。
function c23020408.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上（表侧表示）和墓地的所有符合cfilter的卡，用于统计种类数。
	local g=Duel.GetMatchingGroup(c23020408.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 发动条件：统计出的种类数ct必须大于0，且发动者能抽ct张卡，否则不能发动。
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 将当前连锁的目标玩家设为发动者tp，即抽牌玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设为统计出的种类数ct，供效果处理时使用。
	Duel.SetTargetParam(ct)
	-- 设置操作信息为：预定抽ct张卡，目标玩家为tp，便于其他卡连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- ②效果处理：获取发动时设定的目标玩家和当前统计的种类数，让该玩家抽相应数量的卡。
function c23020408.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取得发动时设置的目标玩家（抽牌玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果处理时重新获取双方场上·墓地符合条件的卡，以计算当前种类数。
	local g=Duel.GetMatchingGroup(c23020408.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 让玩家p以效果原因抽取ct张卡。
	Duel.Draw(p,ct,REASON_EFFECT)
end
