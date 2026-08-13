--D・スピードユニット
-- 效果：
-- 从自己手卡让1只名字带有「变形斗士」的怪兽回到卡组。场上1张卡破坏，从自己卡组抽1张卡。
function c44424095.initial_effect(c)
	-- 从自己手卡让1只名字带有「变形斗士」的怪兽回到卡组。场上1张卡破坏，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c44424095.target)
	e1:SetOperation(c44424095.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤器：选择手牌中满足名字带有「变形斗士」、是怪兽且可以返回卡组的卡。
function c44424095.filter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 定义目标选择函数：在发动时确认条件（手牌有可回卡组的变形斗士、场上有可取对象、能抽卡），并处理取对象目标合法性的检查。
function c44424095.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 检查手牌是否存在至少1张满足filter的「变形斗士」怪兽（用于发动条件）。
	if chk==0 then return Duel.IsExistingMatchingCard(c44424095.filter,tp,LOCATION_HAND,0,1,nil)
		-- 检查场上是否存在至少1张能够成为效果对象的卡（排除本卡自身，用于选择破坏目标）。
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		-- 检查当前玩家tp是否能够抽1张卡。
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 向tp玩家显示选择破坏目标的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让tp玩家从双方场上选择1张卡作为破坏对象（不能选择本卡自身），并将其登记为当前连锁的对象。
	local dg=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：本次连锁包含破坏效果，目标为已选择的dg，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	-- 设置操作信息：本次连锁包含回卡组效果，处理时从tp手牌选择1张卡返回卡组（目标不确定所以为nil，count为1，位置为手牌）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：本次连锁包含抽卡效果，预计tp抽1张卡（targets为nil，参数1表示抽卡数量）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果处理函数：先选择1只「变形斗士」怪兽返回卡组并洗牌，再破坏之前选定的卡片，若破坏成功则抽1张卡。
function c44424095.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在处理时提示tp玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从tp手牌中选择1张满足filter的「变形斗士」怪兽返回卡组。
	local g=Duel.SelectMatchingCard(tp,c44424095.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 向对方玩家确认选择返回卡组的卡。
	Duel.ConfirmCards(1-tp,g)
	-- 将选择的卡以效果原因返回持有者卡组，SEQ_DECKSHUFFLE表示返回后需要洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切tp玩家的卡组。
	Duel.ShuffleDeck(tp)
	-- 获取发动时选择的破坏目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 中断当前效果处理，使破坏和抽卡作为不同时点的动作（避免时点被合并导致错过判定）。
		Duel.BreakEffect()
		-- 破坏目标卡片；若破坏失败（返回0）则结束效果，不进行抽卡。
		if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
		-- tp玩家从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
