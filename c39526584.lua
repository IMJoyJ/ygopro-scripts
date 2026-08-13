--ギフトカード
-- 效果：
-- 对方回复3000基本分。
function c39526584.initial_effect(c)
	-- 对方回复3000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c39526584.target)
	e1:SetOperation(c39526584.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时点的目标处理：无条件允许发动，设置对象玩家为对方、恢复值为3000，并登记回复效果的操作信息。
function c39526584.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁处理的对象玩家设为对方（1-tp），表示由对方回复基本分。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁处理的对象参数设为3000，表示回复基本分的数值。
	Duel.SetTargetParam(3000)
	-- 向决斗系统登记本次操作的信息：类型为回复效果，目标玩家为对方（1-tp），回复数值为3000，不指定具体卡片对象（nil），数量为0。该信息用于精灵之镜等卡的连锁发动判定。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,3000)
end
-- 效果处理时的操作函数：从连锁信息中取出对象玩家和回复数值，执行回复基本分的处理。
function c39526584.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设定好的对象玩家p和对象参数d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 令玩家p回复d点基本分，回复来源为效果，即执行“对方回复3000基本分”。
	Duel.Recover(p,d,REASON_EFFECT)
end
