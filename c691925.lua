--ソーラー・エクスチェンジ
-- 效果：
-- ①：从手卡丢弃1只「光道」怪兽才能发动。自己抽2张。那之后，从自己卡组上面把2张卡送去墓地。
function c691925.initial_effect(c)
	-- ①：从手卡丢弃1只「光道」怪兽才能发动。自己抽2张。那之后，从自己卡组上面把2张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c691925.cost)
	e1:SetTarget(c691925.target)
	e1:SetOperation(c691925.activate)
	c:RegisterEffect(e1)
end
-- 过滤手牌中可丢弃的「光道」怪兽
function c691925.costfilter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 发动代价：从手卡丢弃1只「光道」怪兽
function c691925.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可作为发动代价丢弃的「光道」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c691925.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中丢弃1只「光道」怪兽作为发动代价
	Duel.DiscardHand(tp,c691925.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 效果发动时的合法性检测与操作信息注册
function c691925.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够抽2张卡，以及是否能够将卡组顶端的卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsPlayerCanDiscardDeck(tp,2)
		-- 检查玩家卡组数量是否至少有4张（抽2张加送墓2张）
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为2
	Duel.SetTargetParam(2)
	-- 设置操作信息：包含抽卡效果，预计抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置操作信息：包含卡组送去墓地效果，预计送去墓地2张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- 效果处理：自己抽2张，那之后从卡组上面把2张卡送去墓地
function c691925.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和参数（即自己和抽卡数量2）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果，让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
	-- 中断当前效果处理，使后续的送去墓地处理不与抽卡同时进行
	Duel.BreakEffect()
	-- 将自己卡组最上方的2张卡送去墓地
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
end
