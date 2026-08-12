--EMキャスト・チェンジ
-- 效果：
-- 「娱乐伙伴阵容更换」在1回合只能发动1张。
-- ①：把手卡的「娱乐伙伴」怪兽任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量＋1张。
function c71705144.initial_effect(c)
	-- 「娱乐伙伴阵容更换」在1回合只能发动1张。①：把手卡的「娱乐伙伴」怪兽任意数量给对方观看，回到卡组洗切。那之后，自己从卡组抽出回到卡组的数量＋1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,71705144+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c71705144.target)
	e1:SetOperation(c71705144.activate)
	c:RegisterEffect(e1)
end
-- 过滤手牌中未公开的「娱乐伙伴」怪兽卡且可以回到卡组
function c71705144.filter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and not c:IsPublic()
end
-- 效果发动的检测与目标处理
function c71705144.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 并且检查手牌中是否存在至少1张可以回到卡组的「娱乐伙伴」怪兽
		and Duel.IsExistingMatchingCard(c71705144.filter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息，表示将手牌中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行函数
function c71705144.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 提示玩家选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择手牌中任意数量的「娱乐伙伴」怪兽
	local g=Duel.SelectMatchingCard(p,c71705144.filter,p,LOCATION_HAND,0,1,63,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽给对方确认
		Duel.ConfirmCards(1-p,g)
		-- 将选中的怪兽送回卡组并洗切，并记录实际送回卡组的数量
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(p)
		-- 中断当前效果，使后续的抽卡处理不与回卡组同时进行
		Duel.BreakEffect()
		-- 自己从卡组抽出送回卡组的数量＋1张卡
		Duel.Draw(p,ct+1,REASON_EFFECT)
	end
end
