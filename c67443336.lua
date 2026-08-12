--裁きの天秤
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方场上的卡数量比自己的手卡·场上的卡合计数量多的场合才能发动。自己从卡组抽出那个相差的数量。
function c67443336.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方场上的卡数量比自己的手卡·场上的卡合计数量多的场合才能发动。自己从卡组抽出那个相差的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,67443336+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c67443336.condition)
	e1:SetTarget(c67443336.target)
	e1:SetOperation(c67443336.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：对方场上的卡数量是否比自己的手卡·场上的卡合计数量多
function c67443336.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的卡数量
	local t=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 获取自己手卡和场上的卡合计数量
	local s=Duel.GetFieldGroupCount(tp,LOCATION_HAND+LOCATION_ONFIELD,0)
	return t>s
end
-- 效果发动的目标选择与检测：检查玩家是否能抽相差数量的卡，并设置抽卡的目标玩家、抽卡数量以及操作信息
function c67443336.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的卡数量
	local t=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 获取自己手卡和场上的卡合计数量
	local s=Duel.GetFieldGroupCount(tp,LOCATION_HAND+LOCATION_ONFIELD,0)
	-- 在发动检测时，检查自己是否可以从卡组抽出相差数量的卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,t-s) end
	-- 设置抽卡的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡的目标参数为相差的数量
	Duel.SetTargetParam(t-s)
	-- 设置效果处理的操作信息为“自己抽相差数量的卡”
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,t-s)
end
-- 效果处理的执行：获取目标玩家，重新计算相差数量，若对方场上的卡数量仍较多，则让目标玩家抽出相差数量的卡
function c67443336.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新获取对方场上的卡数量
	local t=Duel.GetFieldGroupCount(p,0,LOCATION_ONFIELD)
	-- 重新获取自己手卡和场上的卡合计数量
	local s=Duel.GetFieldGroupCount(p,LOCATION_HAND+LOCATION_ONFIELD,0)
	if t>s then
		-- 让目标玩家因效果抽相差数量的卡
		Duel.Draw(p,t-s,REASON_EFFECT)
	end
end
