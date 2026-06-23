--無謀な欲張り
-- 效果：
-- ①：自己从卡组抽2张，那之后的自己抽卡阶段跳过2次。
function c37576645.initial_effect(c)
	-- ①：自己从卡组抽2张，那之后的自己抽卡阶段跳过2次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c37576645.target)
	e1:SetOperation(c37576645.activate)
	c:RegisterEffect(e1)
end
-- 检查玩家是否可以抽2张卡并设置抽卡效果相关信息
function c37576645.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为2
	Duel.SetTargetParam(2)
	-- 设置操作信息为抽卡效果，抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 处理效果发动，执行抽卡并设置跳过抽卡阶段效果
function c37576645.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
	-- 那之后的自己抽卡阶段跳过2次。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END,5)
	-- 将跳过抽卡阶段的效果注册给目标玩家
	Duel.RegisterEffect(e1,tp)
end
