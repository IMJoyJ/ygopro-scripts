--コア濃度圧縮
-- 效果：
-- 把手卡1张「核成兽的钢核」给对方观看，从手卡丢弃1只名字带有「核成」的怪兽发动。从自己卡组抽2张卡。
function c13997673.initial_effect(c)
	-- 在卡上登记「核成兽的钢核」的卡号（36623431），用于效果文本引用和相关判定。
	aux.AddCodeList(c,36623431)
	-- 把手卡1张「核成兽的钢核」给对方观看，从手卡丢弃1只名字带有「核成」的怪兽发动。从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c13997673.cost)
	e1:SetTarget(c13997673.target)
	e1:SetOperation(c13997673.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手牌中存在「核成兽的钢核」且当前为非公开状态，用于选择给对方展示的钢核。
function c13997673.cfilter1(c)
	return c:IsCode(36623431) and not c:IsPublic()
end
-- 过滤条件：手牌中存在名字带有「核成」的怪兽且可以作为代价丢弃，用于选择丢弃的核成怪兽。
function c13997673.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1d) and c:IsDiscardable()
end
-- 代价检测函数：在发动前确认手牌是否同时满足“有可展示的钢核”和“有可丢弃的核成怪兽”两个条件。
function c13997673.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动者的手牌中是否存在至少1张满足cfilter1条件的「核成兽的钢核」。
	if chk==0 then return Duel.IsExistingMatchingCard(c13997673.cfilter1,tp,LOCATION_HAND,0,1,nil)
		-- 同时检查发动者的手牌中是否存在至少1张满足cfilter2条件的名字带有「核成」的怪兽。
		and Duel.IsExistingMatchingCard(c13997673.cfilter2,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，让发动者选择一张要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌中选择1张「核成兽的钢核」用于给对方观看。
	local g1=Duel.SelectMatchingCard(tp,c13997673.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的「核成兽的钢核」展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g1)
	-- 弹出选择提示，让发动者选择一张要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌中选择1只名字带有「核成」的怪兽作为发动代价。
	local g2=Duel.SelectMatchingCard(tp,c13997673.cfilter2,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的核成怪兽送去墓地，此次送墓的原因为“代价+丢弃”。
	Duel.SendtoGrave(g2,REASON_COST+REASON_DISCARD)
	-- 洗切发动者的手牌，以重置手牌顺序。
	Duel.ShuffleHand(tp)
end
-- 目标设定函数：确认可以抽2张卡，并记录抽卡玩家及抽卡数量，供处理时使用。
function c13997673.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查发动者是否可以进行效果抽卡，且张数为2。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设置为发动者tp，即最终执行抽卡的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为2，即抽卡张数。
	Duel.SetTargetParam(2)
	-- 设置操作信息，向系统声明这是一个抽2张卡的效果，用于触发相关时点和检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：实际执行从卡组抽2张卡的动作。
function c13997673.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前记录的抽卡玩家p和抽卡数量d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
