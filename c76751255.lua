--イグナイト・リロード
-- 效果：
-- 「点火骑士上膛」在1回合只能发动1张。
-- ①：把手卡的灵摆怪兽任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量＋1张。这张卡的发动后，直到回合结束时自己不能用卡的效果抽卡。
function c76751255.initial_effect(c)
	-- 「点火骑士上膛」在1回合只能发动1张。①：把手卡的灵摆怪兽任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量＋1张。这张卡的发动后，直到回合结束时自己不能用卡的效果抽卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,76751255+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c76751255.target)
	e1:SetOperation(c76751255.activate)
	c:RegisterEffect(e1)
end
-- 过滤手牌中可以回到卡组且未公开的灵摆怪兽
function c76751255.filter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToDeck() and not c:IsPublic()
end
-- 效果发动的可行性检测与效果处理准备
function c76751255.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否具有抽卡的效果许可
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查手牌中是否存在至少1张可以回到卡组的灵摆怪兽
		and Duel.IsExistingMatchingCard(c76751255.filter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 将当前效果的对象玩家设置为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的操作信息为将手牌的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行逻辑，包含展示、洗回、抽卡及后续限制
function c76751255.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家（即发动玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 提示玩家选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手牌选择任意数量（1-63张）满足过滤条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(p,c76751255.filter,p,LOCATION_HAND,0,1,63,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽给对方玩家确认
		Duel.ConfirmCards(1-p,g)
		-- 将选中的卡片送回卡组洗切，并记录实际送回卡组的卡片数量
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切目标玩家的卡组
		Duel.ShuffleDeck(p)
		-- 划分效果处理的时点，使后续的抽卡处理不与送回卡组同时进行
		Duel.BreakEffect()
		-- 玩家从卡组抽出送回卡组数量+1张卡
		Duel.Draw(p,ct+1,REASON_EFFECT)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不能用卡的效果抽卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册该限制效果，使玩家直到回合结束时不能用卡的效果抽卡
	Duel.RegisterEffect(e1,tp)
end
