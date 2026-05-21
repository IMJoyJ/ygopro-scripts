--謙虚な番兵
-- 效果：
-- 自己手卡公开，从那之中选1张卡回到卡组。
function c95642274.initial_effect(c)
	-- 自己手卡公开，从那之中选1张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c95642274.target)
	e1:SetOperation(c95642274.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：手牌中存在可以回到卡组的卡，且手牌中没有已公开的卡
function c95642274.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身手牌中（不含这张卡）是否存在至少1张可以回到卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 检查自身手牌中（不含这张卡）是否不存在已公开的卡（若有则不能发动）
		and not Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 将当前连锁的对象玩家设置为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：从手牌将1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：公开手牌，选择1张手牌回到卡组，之后洗牌
function c95642274.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取该玩家的所有手牌
	local cg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	-- 将这些手牌给对方玩家确认（公开手牌）
	Duel.ConfirmCards(1-p,cg)
	-- 获取该玩家手牌中所有可以回到卡组的卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
	if g:GetCount()>=1 then
		-- 提示玩家选择要放入卡组的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(p,1,1,nil)
		-- 将选中的卡送回卡组并洗牌
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	-- 洗切该玩家的其余手牌
	Duel.ShuffleHand(p)
end
