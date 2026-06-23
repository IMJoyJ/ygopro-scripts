--D・スピードユニット
-- 效果：
-- 从自己手卡让1只名字带有「变形斗士」的怪兽回到卡组。场上1张卡破坏，从自己卡组抽1张卡。
function c44424095.initial_effect(c)
	-- 效果定义：从自己手卡让1只名字带有「变形斗士」的怪兽回到卡组。场上1张卡破坏，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c44424095.target)
	e1:SetOperation(c44424095.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择手卡中名字带有「变形斗士」的怪兽
function c44424095.filter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果处理条件判断：检查是否满足发动条件
function c44424095.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 检查手卡中是否存在名字带有「变形斗士」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44424095.filter,tp,LOCATION_HAND,0,1,nil)
		-- 检查场上是否存在可破坏的卡
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		-- 检查玩家是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local dg=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：破坏对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	-- 设置操作信息：将手卡中的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果发动处理：选择并送回手卡中的怪兽，破坏场上卡，抽卡
function c44424095.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择手卡中满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c44424095.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 向对方确认选择的怪兽
	Duel.ConfirmCards(1-tp,g)
	-- 将选择的怪兽送回卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切自己的卡组
	Duel.ShuffleDeck(tp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 破坏目标卡
		if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
		-- 从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
