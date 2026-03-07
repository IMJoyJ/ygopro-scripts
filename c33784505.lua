--壺盗み
-- 效果：
-- 「强欲之壶」发动时才能发动。使「强欲之壶」的效果无效，从自己卡组抽1张卡。
function c33784505.initial_effect(c)
	-- 创建效果并设置其类型为魔法卡发动，触发条件为连锁发动，效果分类为使效果无效和抽卡，条件函数为c33784505.condition，目标函数为c33784505.target，发动函数为c33784505.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c33784505.condition)
	e1:SetTarget(c33784505.target)
	e1:SetOperation(c33784505.activate)
	c:RegisterEffect(e1)
end
-- 连锁发动时的条件判断函数，用于判断是否满足发动条件
function c33784505.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁的发动是否为魔法卡发动、连锁的卡是否为「强欲之壶」、以及该连锁是否可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(55144522) and Duel.IsChainNegatable(ev)
end
-- 效果发动时的目标设定函数，用于检查是否可以抽卡并设置操作信息
function c33784505.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息，将「强欲之壶」的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 设置操作信息，使自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果发动时的处理函数，用于执行效果的最终处理
function c33784505.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使连锁的效果无效
	if Duel.NegateEffect(ev) then
		-- 让玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
