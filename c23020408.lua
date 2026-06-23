--魂のしもべ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从自己的手卡·卡组·墓地选除「魂之仆人」外的1只「黑魔术师」或「黑魔术少女」或者1张有那其中任意种的卡名记述的卡在卡组最上面放置。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。自己抽出双方的场上·墓地的「守护神官」怪兽、「黑魔术师」、「黑魔术少女」种类的数量。
function c23020408.initial_effect(c)
	-- 注册卡片效果中涉及的其他卡名代码，用于后续判断是否为黑魔术师或黑魔术少女相关卡
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
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。自己抽出双方的场上·墓地的「守护神官」怪兽、「黑魔术师」、「黑魔术少女」种类的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23020408,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,23020408)
	-- 设置效果发动时需要将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c23020408.drtg)
	e2:SetOperation(c23020408.drop)
	c:RegisterEffect(e2)
end
-- 定义用于筛选符合条件的卡的过滤函数，包括黑魔术师、黑魔术少女及其记述卡，且不能是魂之仆人本身，同时必须能被送入卡组
function c23020408.filter(c)
	-- 筛选条件：卡号为黑魔术师或黑魔术少女，或为黑魔术族怪兽，且不是魂之仆人
	return (aux.IsCodeOrListed(c,46986414) or aux.IsCodeOrListed(c,38033121)) and not c:IsCode(23020408)
		and (c:IsAbleToDeck() or c:IsLocation(LOCATION_DECK))
end
-- 效果发动时的处理函数，检查是否满足条件并设置操作信息
function c23020408.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家在手牌、卡组、墓地中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c23020408.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，表示将有1张卡从手牌或墓地送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果发动时的处理函数，用于选择并放置符合条件的卡到卡组最上方
function c23020408.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置在卡组最上方的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23020408,2))  --"请选择要放置在卡组最上面的卡"
	-- 选择满足条件的卡，从手牌、卡组、墓地中选取一张
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c23020408.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将玩家卡组洗牌
		Duel.ShuffleDeck(tp)
		-- 显示选中卡作为对象的动画效果
		Duel.HintSelection(g)
		if tc:IsLocation(LOCATION_DECK) then
			-- 如果卡已在卡组中，则将其移动到卡组最上方
			Duel.MoveSequence(tc,SEQ_DECKTOP)
		else
			-- 如果卡不在卡组中，则将其送入卡组最上方
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
		if tc:IsLocation(LOCATION_DECK) then
			-- 确认卡组最上方的卡
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
-- 定义用于筛选双方场上或墓地中符合条件的卡的过滤函数，包括黑魔术师、黑魔术少女及其记述卡，且必须是表侧表示或在墓地
function c23020408.cfilter(c)
	return (c:IsCode(46986414,38033121) or (c:IsSetCard(0x139) and c:IsType(TYPE_MONSTER))) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 设置效果发动时的处理函数，计算符合条件的种类数量并检查是否可以抽卡
function c23020408.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上或墓地中符合条件的卡组
	local g=Duel.GetMatchingGroup(c23020408.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 检查是否满足抽卡条件，即存在符合条件的卡且玩家可以抽相应数量的卡
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置当前连锁的目标玩家为效果发动者
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为抽卡数量
	Duel.SetTargetParam(ct)
	-- 设置操作信息，表示将进行抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果发动时的处理函数，执行抽卡操作
function c23020408.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取双方场上或墓地中符合条件的卡组
	local g=Duel.GetMatchingGroup(c23020408.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 让目标玩家以效果原因抽相应数量的卡
	Duel.Draw(p,ct,REASON_EFFECT)
end
