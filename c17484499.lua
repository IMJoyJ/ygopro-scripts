--現世と冥界の逆転
-- 效果：
-- 这个卡名的卡在决斗中只能发动1张。
-- ①：双方墓地的卡各自是15张以上的场合支付1000基本分才能发动。双方玩家各自把自身的卡组和墓地的卡全部交换，那之后卡组洗切。
function c17484499.initial_effect(c)
	-- 这个卡名的卡在决斗中只能发动1张。①：双方墓地的卡各自是15张以上的场合支付1000基本分才能发动。双方玩家各自把自身的卡组和墓地的卡全部交换，那之后卡组洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DRAW_PHASE)
	e1:SetCountLimit(1,17484499+EFFECT_COUNT_CODE_DUEL+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c17484499.condition)
	e1:SetCost(c17484499.cost)
	e1:SetOperation(c17484499.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：以发动玩家视角，己方墓地和对方墓地的卡数均不少于15张。
function c17484499.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方墓地卡数是否不少于15张。
	return Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)>=15
		-- 检查对方墓地卡数是否不少于15张。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>=15
end
-- 发动代价：支付1000基本分。
function c17484499.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认玩家能否支付1000基本分，若不能则无法发动。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际扣除玩家1000基本分，作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 效果处理：获取双方墓地全部卡，若未因王家长眠之谷等效果被无效，则交换双方玩家各自的卡组与墓地（之后卡组洗切）。
function c17484499.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方墓地的全部卡作为对象集合，用于检查是否受王家长眠之谷影响。
	local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,LOCATION_GRAVE)
	-- 若集合中存在受王家长眠之谷影响且当前连锁可被无效的卡，则自动无效本效果并停止后续交换。
	if aux.NecroValleyNegateCheck(g) then return end
	-- 将发动玩家的卡组与墓地全部交换，随后卡组洗切。
	Duel.SwapDeckAndGrave(tp)
	-- 将对方玩家的卡组与墓地全部交换，随后卡组洗切。
	Duel.SwapDeckAndGrave(1-tp)
end
