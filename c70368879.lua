--成金ゴブリン
-- 效果：
-- ①：自己从卡组抽1张。那之后，对方回复1000基本分。
function c70368879.initial_effect(c)
	-- ①：自己从卡组抽1张。那之后，对方回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c70368879.target)
	e1:SetOperation(c70368879.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标检查与准备（设置抽卡和回复的操作信息）
function c70368879.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己是否满足抽1张卡的条件
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置操作信息，表明此效果包含“自己抽1张卡”的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置操作信息，表明此效果包含“对方回复1000基本分”的操作
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
end
-- 效果处理的执行（自己抽卡，那之后对方回复基本分）
function c70368879.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中预设的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果，并确认是否成功抽卡
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		-- 中断效果处理，使“抽卡”与“回复基本分”不视为同时处理
		Duel.BreakEffect()
		-- 使对方回复1000基本分
		Duel.Recover(1-tp,1000,REASON_EFFECT)
	end
end
