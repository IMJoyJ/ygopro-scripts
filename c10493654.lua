--Ai－コンタクト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的场地区域有「火灵天星“艾”心乐园岛」存在的场合，把手卡1张「火灵天星“艾”心乐园岛」给对方观看才能发动。给人观看的卡回到卡组最下面，自己从卡组抽3张。
function c10493654.initial_effect(c)
	-- 将卡号59054773（火灵天星“艾”心乐园岛）登记到本卡的代码列表中，用于效果文本中提及该卡的关联显示。
	aux.AddCodeList(c,59054773)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的场地区域有「火灵天星“艾”心乐园岛」存在的场合，把手卡1张「火灵天星“艾”心乐园岛」给对方观看才能发动。给人观看的卡回到卡组最下面，自己从卡组抽3张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10493654,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,10493654+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c10493654.condition)
	e1:SetCost(c10493654.cost)
	e1:SetTarget(c10493654.target)
	e1:SetOperation(c10493654.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：手牌中卡号为59054773、非公开状态且能够返回卡组的卡，作为可展示并送回卡组底部的对象。
function c10493654.cfilter(c)
	return c:IsCode(59054773) and not c:IsPublic() and c:IsAbleToDeck()
end
-- 效果发动条件：自己的场地区域存在「火灵天星“艾”心乐园岛」。
function c10493654.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡号59054773的场地卡是否在自己场上区域生效（由tp控制）。若成立则满足条件。
	return Duel.IsEnvironment(59054773,tp,LOCATION_FZONE)
end
-- 发动代价判定：先设置标记1表示已确认要进行展示手卡的操作；在规则上代价为展示手卡，但具体选择放到目标处理阶段执行，因此chk==0时直接返回true表示代价可支付。
function c10493654.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 目标选择和发动合法性检查：在发动时确认手卡有可展示的「火灵天星“艾”心乐园岛」且能抽3张，然后选择1张给对方确认，并将该卡设为对象；同时设定回卡组和抽卡的操作信息。
function c10493654.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查手卡存在满足cfilter的卡，并且tp能抽3张卡，以此作为效果可否发动的条件。
		return Duel.IsExistingMatchingCard(c10493654.cfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp,3)
	end
	e:SetLabel(0)
	-- 向tp发出选择提示，提示内容为“请选择给对方确认的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从tp的手卡中选择1张满足cfilter条件的卡（即「火灵天星“艾”心乐园岛」），作为给对方确认并送回卡组底部的对象。
	local g=Duel.SelectMatchingCard(tp,c10493654.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切tp的手卡，避免公开卡位信息影响手牌顺序。
	Duel.ShuffleHand(tp)
	-- 将选择的卡设置为当前连锁的对象，使后续处理时能检查该卡是否仍与效果关联。
	Duel.SetTargetCard(g)
	-- 设定本次效果操作信息：包含回卡组效果，对象为g，数量为1，对象归属玩家未知（用0），位置为0（回卡组），用于连锁相关检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设定本次效果操作信息：包含抽卡效果，目标玩家为tp，预计抽3张，因抽出的卡不确定所以对象为nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 效果处理：取得之前选择的对象卡，若其仍与效果关联且成功送回卡组最下面，则tp抽3张卡。
function c10493654.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的第一张对象卡（即展示并选择的那张「火灵天星“艾”心乐园岛」）。
	local tc=Duel.GetFirstTarget()
	-- 判定该对象卡仍与效果关联，且成功将其送回卡组最下面（返回非0）并已在卡组区域时，才执行后续抽卡。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) then
		-- 让tp以效果原因抽取3张卡。
		Duel.Draw(tp,3,REASON_EFFECT)
	end
end
