--スケルエンジェル
-- 效果：
-- ①：这张卡反转的场合发动。自己从卡组抽1张。
function c60694662.initial_effect(c)
	-- ①：这张卡反转的场合发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60694662,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c60694662.target)
	e1:SetOperation(c60694662.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标与操作信息
function c60694662.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：由发动效果的玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果处理的执行函数
function c60694662.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家及对象参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果从卡组抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
