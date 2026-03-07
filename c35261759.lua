--強欲で貪欲な壺
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己卡组上面把10张卡里侧表示除外才能发动。自己从卡组抽2张。
function c35261759.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35261759+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c35261759.cost)
	e1:SetTarget(c35261759.target)
	e1:SetOperation(c35261759.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查是否满足费用条件，即从卡组上方取10张卡里侧表示除外且卡组剩余不少于12张卡。
function c35261759.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：获取玩家卡组最上方的10张卡组成的卡片组。
	local g=Duel.GetDecktopGroup(tp,10)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==10
		-- 效果作用：确保卡组中剩余卡数不少于12张，以满足后续操作需求。
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=12 end
	-- 效果作用：禁止接下来的操作自动洗切卡组。
	Duel.DisableShuffleCheck()
	-- 效果作用：将之前获取的10张卡以里侧表示的方式除外作为发动费用。
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 效果原文内容：①：从自己卡组上面把10张卡里侧表示除外才能发动。自己从卡组抽2张。
function c35261759.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 效果作用：设置连锁的目标玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置连锁的目标参数为2（表示要抽2张卡）。
	Duel.SetTargetParam(2)
	-- 效果作用：设置当前连锁的操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果作用：执行效果，使目标玩家从卡组抽2张卡。
function c35261759.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标玩家和目标参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：使目标玩家从卡组中抽取指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
