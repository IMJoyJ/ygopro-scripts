--強欲で貪欲な壺
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己卡组上面把10张卡里侧表示除外才能发动。自己从卡组抽2张。
function c35261759.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己卡组上面把10张卡里侧表示除外才能发动。自己从卡组抽2张。
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
-- 代价检查：获取卡组最上方10张卡；若为发动确认阶段，则判定这10张卡都能作为里侧表示除外代价，且卡组剩余数量不少于12张（确保除外10张后至少还有2张可抽）。
function c35261759.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家tp卡组最上方的10张卡，作为将要里侧除外代价的候选卡组。
	local g=Duel.GetDecktopGroup(tp,10)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==10
		-- 同时要求玩家tp的卡组剩余数量不少于12张，以保证除外10张后还能抽2张卡。
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=12 end
	-- 禁止系统在本次操作后自动进行洗切卡组检测，因为从卡组顶端精确除外10张卡不需要洗切。
	Duel.DisableShuffleCheck()
	-- 将选定的10张卡以里侧表示除外，作为发动这张卡的代价。
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 效果发动时设置目标：检查tp玩家能否抽2张卡；若可以，则将当前连锁的对象玩家设为tp、对象参数设为2，并宣告本次操作为抽2张卡。
function c35261759.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动确认阶段，判断玩家tp是否可以抽2张卡，作为效果能否发动的条件之一。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁处理的对象玩家设置为tp，即执行抽卡的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁处理的对象参数设置为2，表示要抽的卡数为2。
	Duel.SetTargetParam(2)
	-- 设置操作信息：当前连锁将进行抽卡效果，目标玩家为tp，抽卡数为2（不取对象），供其他卡片的发动/无效等效果进行响应判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：从连锁信息中取出之前保存的对象玩家和抽卡数，让该玩家抽相应数量的卡。
function c35261759.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得对象玩家p和对象参数d（抽卡数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，完成抽卡效果的处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
