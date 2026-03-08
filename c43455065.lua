--魔力の泉
-- 效果：
-- 「魔力之泉」在1回合只能发动1张。
-- ①：自己从卡组抽出对方场上的表侧表示的魔法·陷阱卡的数量。那之后，从自己手卡选自己场上的表侧表示的魔法·陷阱卡数量的卡丢弃。这张卡的发动后，直到下次的对方回合的结束时，对方场上的魔法·陷阱卡不会被破坏，发动和效果不会被无效化。
function c43455065.initial_effect(c)
	-- ①：自己从卡组抽出对方场上的表侧表示的魔法·陷阱卡的数量。那之后，从自己手卡选自己场上的表侧表示的魔法·陷阱卡数量的卡丢弃。这张卡的发动后，直到下次的对方回合的结束时，对方场上的魔法·陷阱卡不会被破坏，发动和效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,43455065+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c43455065.target)
	e1:SetOperation(c43455065.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上表侧表示的魔法·陷阱卡
function c43455065.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果处理：计算对方场上的魔法·陷阱卡数量并检查是否可以抽卡
function c43455065.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算对方场上的魔法·陷阱卡数量
	local ct=Duel.GetMatchingGroupCount(c43455065.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 若未满足条件则返回false
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为对方场上的魔法·陷阱卡数量
	Duel.SetTargetParam(ct)
	-- 设置效果操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果处理：执行抽卡和丢弃手卡操作
function c43455065.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算对方场上的魔法·陷阱卡数量
	local ct=Duel.GetMatchingGroupCount(c43455065.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 执行抽卡操作并判断是否成功
	if Duel.Draw(p,ct,REASON_EFFECT)~=0 then
		-- 重新计算己方场上的魔法·陷阱卡数量
		ct=Duel.GetMatchingGroupCount(c43455065.filter,tp,LOCATION_ONFIELD,0,nil)
		if ct>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 丢弃指定数量的手卡
			Duel.DiscardHand(tp,nil,ct,ct,REASON_EFFECT+REASON_DISCARD)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	local rct=1
	-- 判断是否为对方回合以确定持续回合数
	if Duel.GetTurnPlayer()~=tp then rct=2 end
	local c=e:GetHandler()
	-- 创建并注册效果：对方场上的魔法·陷阱卡不会被效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(0,LOCATION_ONFIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTarget(c43455065.indtg)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,rct)
	-- 将效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	-- 将效果注册给当前玩家
	Duel.RegisterEffect(e2,tp)
	-- 创建并注册效果：对方不能无效化魔法·陷阱卡的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetValue(c43455065.efilter)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,rct)
	-- 将效果注册给当前玩家
	Duel.RegisterEffect(e2,tp)
	-- 创建并注册效果：对方不能将魔法·陷阱卡的效果无效化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISEFFECT)
	e3:SetValue(c43455065.efilter)
	e3:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,rct)
	-- 将效果注册给当前玩家
	Duel.RegisterEffect(e3,tp)
	-- 创建并注册效果：对方不能将魔法·陷阱卡的效果无效化
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISABLE)
	e4:SetTargetRange(0,LOCATION_ONFIELD)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetTarget(c43455065.indtg)
	e4:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,rct)
	-- 将效果注册给当前玩家
	Duel.RegisterEffect(e4,tp)
end
-- 用于判断目标卡是否为魔法·陷阱卡
function c43455065.indtg(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 用于判断触发效果是否为魔法·陷阱卡
function c43455065.efilter(e,ct)
	-- 获取连锁中触发效果和触发玩家
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	local tc=te:GetHandler()
	return tp~=e:GetHandlerPlayer() and tc:IsType(TYPE_SPELL+TYPE_TRAP)
end
