--補給部隊
-- 效果：
-- ①：1回合1次，自己场上的怪兽被战斗·效果破坏的场合发动。自己抽1张。
function c17626381.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己场上的怪兽被战斗·效果破坏的场合发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17626381,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1)
	e2:SetCondition(c17626381.drcon)
	e2:SetTarget(c17626381.drtg)
	e2:SetOperation(c17626381.drop)
	c:RegisterEffect(e2)
end
-- 检查被破坏的怪兽是否由战斗或效果破坏且之前在自己场上
function c17626381.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 判断是否有满足条件的怪兽被破坏
function c17626381.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c17626381.cfilter,1,nil,tp)
end
-- 设置效果的发动对象和参数，准备执行抽卡效果
function c17626381.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为抽卡效果，目标玩家为自己，抽卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果，从自己牌组抽1张卡
function c17626381.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家从自己牌组抽指定数量的卡，原因设为效果
	Duel.Draw(p,d,REASON_EFFECT)
end
