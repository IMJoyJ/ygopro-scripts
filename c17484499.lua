--現世と冥界の逆転
-- 效果：
-- 这个卡名的卡在决斗中只能发动1张。
-- ①：双方墓地的卡各自是15张以上的场合支付1000基本分才能发动。双方玩家各自把自身的卡组和墓地的卡全部交换，那之后卡组洗切。
function c17484499.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在决斗中只能发动1张。
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
-- 效果作用：判断双方墓地的卡是否各自达到15张以上
function c17484499.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断自己的墓地卡数量是否达到15张
	return Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)>=15
		-- 效果作用：判断对方的墓地卡数量是否达到15张
		and Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>=15
end
-- 效果作用：支付1000基本分作为发动cost
function c17484499.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 效果作用：支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果作用：发动效果，交换双方卡组与墓地
function c17484499.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取自己的墓地卡组
	local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,LOCATION_GRAVE)
	-- 效果作用：检查是否因王家长眠之谷而无效此效果
	if aux.NecroValleyNegateCheck(g) then return end
	-- 效果作用：交换自己的卡组与墓地
	Duel.SwapDeckAndGrave(tp)
	-- 效果作用：交换对方的卡组与墓地
	Duel.SwapDeckAndGrave(1-tp)
end
