--ダメージ・ポラリライザー
-- 效果：
-- 给与伤害的效果发动时才能发动。那个发动和效果无效，双方玩家抽1张卡。
function c46031686.initial_effect(c)
	-- 给与伤害的效果发动时才能发动。那个发动和效果无效，双方玩家抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c46031686.condition)
	e1:SetTarget(c46031686.target)
	e1:SetOperation(c46031686.activate)
	c:RegisterEffect(e1)
end
-- 本卡发动条件判定：当前连锁中存在给予伤害的效果，且发动的效果是怪兽效果或魔法·陷阱卡的发动，且该连锁的发动可以被无效时，满足发动条件。
function c46031686.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中是否存在“给予伤害”类别的操作信息，保存到ex变量。
	local ex=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	-- 返回判定结果：存在伤害效果，且发动效果的类型为怪兽效果或魔法·陷阱卡发动，且该连锁的发动能够被无效。
	return ex and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 效果发动时的目标与合法性判定：确认双方玩家是否都能抽1张卡，并将无效发动与双方抽卡的操作信息登记到连锁。
function c46031686.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查双方玩家是否都能抽1张卡，若任意一方不能抽卡则本卡不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 登记无效发动的操作信息：将当前连锁的发动效果对象（eg）作为无效对象，处理数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 登记抽卡的操作信息：抽卡对象在处理时不固定，双方玩家各抽1张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 效果处理：使目标连锁的发动无效，然后双方玩家各抽1张卡。
function c46031686.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁ev的发动被无效。
	Duel.NegateActivation(ev)
	-- 发动方玩家tp抽1张卡（因效果）。
	Duel.Draw(tp,1,REASON_EFFECT)
	-- 对方玩家（1-tp）抽1张卡（因效果）。
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
