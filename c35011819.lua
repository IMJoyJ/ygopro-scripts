--エンペラー・オーダー
-- 效果：
-- ①：需怪兽召唤成功时发动的怪兽的效果发动时才能把这个效果发动。那个发动无效。那之后，发动无效的玩家从卡组抽1张。
function c35011819.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 注册发动时点为连锁发动的诱发即时效果，满足条件时可以无效怪兽召唤成功时的发动并抽卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35011819,0))  --"无效并抽卡"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c35011819.condition)
	e2:SetTarget(c35011819.target)
	e2:SetOperation(c35011819.activate)
	c:RegisterEffect(e2)
end
-- 效果发动时的条件判断函数
function c35011819.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确保连锁发动的是怪兽类型且为召唤成功事件，并且该连锁可以被无效
	return re:IsActiveType(TYPE_MONSTER) and re:GetCode()==EVENT_SUMMON_SUCCESS and Duel.IsChainNegatable(ev)
end
-- 效果发动时的目标设定函数
function c35011819.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动无效的玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(rp,1) end
	-- 设置当前处理的连锁操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置当前处理的连锁的目标玩家为发动无效的玩家
	Duel.SetTargetPlayer(rp)
	-- 设置当前处理的连锁的目标参数为1（表示抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置当前处理的连锁操作信息为发动玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,rp,1)
end
-- 效果发动时的具体处理函数
function c35011819.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使当前连锁发动无效，若无效失败则直接返回
	if not Duel.NegateActivation(ev) then return end
	-- 获取当前连锁的发动者和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家以效果原因抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
