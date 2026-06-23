--ダメージ・ポラリライザー
-- 效果：
-- 给与伤害的效果发动时才能发动。那个发动和效果无效，双方玩家抽1张卡。
function c46031686.initial_effect(c)
	-- 给与伤害的效果发动时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c46031686.condition)
	e1:SetTarget(c46031686.target)
	e1:SetOperation(c46031686.activate)
	c:RegisterEffect(e1)
end
-- 检查是否为伤害效果发动，且效果可被无效。
function c46031686.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中是否包含伤害效果。
	local ex=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	-- 确认发动效果为怪兽或魔法/陷阱卡，并且连锁可被无效。
	return ex and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 那个发动和效果无效，双方玩家抽1张卡。
function c46031686.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断双方玩家是否可以抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置连锁操作信息为使发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置连锁操作信息为双方各抽一张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 使连锁发动无效并让双方各抽一张卡。
function c46031686.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效。
	Duel.NegateActivation(ev)
	-- 让当前玩家抽一张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
	-- 让对方玩家抽一张卡。
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
