--コアキメイル・グラヴィローズ
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只植物族怪兽给对方观看。或者都不进行让这张卡破坏。自己的准备阶段时只有1次，可以从自己卡组把1只3星以下的怪兽送去墓地。
function c41201555.initial_effect(c)
	-- 将该卡效果外文本中记载的卡名「核成兽的钢核」（卡号36623431）注册进代码列表，用于后续识别该卡记载的其他卡名。
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只植物族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c41201555.mtcon)
	e1:SetOperation(c41201555.mtop)
	c:RegisterEffect(e1)
	-- 自己的准备阶段时只有1次，可以从自己卡组把1只3星以下的怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41201555,3))  --"送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c41201555.condition)
	e2:SetTarget(c41201555.target)
	e2:SetOperation(c41201555.operation)
	c:RegisterEffect(e2)
end
-- 第一效果的发动条件函数：只在当前回合玩家为这张卡的控制者（即自己回合的结束阶段）时允许发动维持COST效果。
function c41201555.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果控制者tp，保证效果只在控制者的回合阶段触发。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数：选择手牌中卡名为「核成兽的钢核」（36623431）且可以作为代价送去墓地的卡，用于“从手卡把1张「核成兽的钢核」送去墓地”的维持代价。
function c41201555.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤函数：选择手牌中未公开的植物族怪兽，作为“把手卡1只植物族怪兽给对方观看”的候选。
function c41201555.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_PLANT) and not c:IsPublic()
end
-- 第一效果（结束阶段维持COST）的结算函数：根据手牌是否存在「核成兽的钢核」和植物族怪兽，让控制者选择对应的维持方式；若选择送墓钢核则执行送墓，若选择展示植物则给对方确认并洗切手牌，若无法或选择不进行维持则破坏这张卡。
function c41201555.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 手动播放这张卡被选为对象/处理的动画，并记录其被选择状态。
	Duel.HintSelection(Group.FromCards(c))
	-- 获取当前控制者手牌中可作为代价送去墓地的「核成兽的钢核」的集合g1。
	local g1=Duel.GetMatchingGroup(c41201555.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取当前控制者手牌中符合展示条件的植物族怪兽的集合g2。
	local g2=Duel.GetMatchingGroup(c41201555.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当两种维持代价都存在时，让玩家从“送钢核/展示植物/破坏”三个选项中选择一个，返回选项序号（0/1/2）。
		select=Duel.SelectOption(tp,aux.Stringid(41201555,0),aux.Stringid(41201555,1),aux.Stringid(41201555,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张植物族怪兽给对方观看/破坏「核成孕妇蔷薇」"
	elseif g1:GetCount()>0 then
		-- 当仅存在「核成兽的钢核」时，提供“送钢核/破坏”两个选项；因为返回值仍要统一为三选项编号，所以若选择破坏（返回1）则映射为2。
		select=Duel.SelectOption(tp,aux.Stringid(41201555,0),aux.Stringid(41201555,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成孕妇蔷薇」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 当仅存在植物族怪兽时，提供“展示植物/破坏”两个选项；返回值加1后映射为1或2，以便后续统一处理。
		select=Duel.SelectOption(tp,aux.Stringid(41201555,1),aux.Stringid(41201555,2))+1  --"选择一张植物族怪兽给对方观看/破坏「核成孕妇蔷薇」"
	else
		-- 当两种代价都没有时，只提供“破坏”选项，并强制select=2表示选择破坏。
		select=Duel.SelectOption(tp,aux.Stringid(41201555,2))  --"破坏「核成孕妇蔷薇」"
		select=2
	end
	if select==0 then
		-- 显示提示文本，要求玩家选择一张要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将玩家选择的「核成兽的钢核」作为维持代价（COST）送去墓地。
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 显示提示文本，要求玩家选择一张要展示给对方确认的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将玩家选择的植物族怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示后洗切该玩家的手牌，以重置公开/展示状态，避免手牌顺序信息泄露。
		Duel.ShuffleHand(tp)
	else
		-- 若玩家未进行送墓或展示，则将该卡自身以规则代价（REASON_COST）破坏。
		Duel.Destroy(c,REASON_COST)
	end
end
-- 第二效果的发动条件函数：当前回合玩家为这张卡的控制者（即自己的准备阶段）时才可发动。
function c41201555.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果控制者tp，确保只在控制者的准备阶段触发。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数：从卡组中筛选等级3以下且可以被效果送去墓地的怪兽，作为“从卡组把1只3星以下的怪兽送去墓地”的候选。
function c41201555.tgfilter(c)
	return c:IsLevelBelow(3) and c:IsAbleToGrave()
end
-- 第二效果的发动合法性与操作信息设置：在发动时检查卡组是否存在符合条件的怪兽，若存在则设置本次效果的信息为从卡组把1张卡送去墓地（不取对象）。
function c41201555.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0（效果发动合法性检查）时，检查卡组是否存在至少1只满足tgfilter条件的怪兽（3星以下且可送墓）。
	if chk==0 then return Duel.IsExistingMatchingCard(c41201555.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，声明本效果将把1张卡从卡组送去墓地，用于后续时点/连锁的判定和检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 第二效果的处理函数：实际执行从卡组选择1只符合条件的怪兽送去墓地的操作。
function c41201555.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示提示文本，要求玩家选择一张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从当前玩家的卡组中选择1张满足tgfilter条件的怪兽（等级3以下且可送去墓地）。
	local g=Duel.SelectMatchingCard(tp,c41201555.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽以效果（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
