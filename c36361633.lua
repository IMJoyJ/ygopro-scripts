--威嚇する咆哮
-- 效果：
-- ①：这个回合对方不能攻击宣言。
function c36361633.initial_effect(c)
	-- ①：这个回合对方不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0xc)
	e1:SetCondition(c36361633.condition)
	e1:SetOperation(c36361633.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：必须由对方回合且当前阶段不是主要阶段2或结束阶段时才能发动，即只能在对方回合的主要阶段1、战斗阶段等可以发动的时点发动。
function c36361633.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 返回条件：当前操作者不是回合玩家（即对方回合），且当前阶段不等于主要阶段2与结束阶段（用位运算判定不属于这两个阶段）。
	return tp~=Duel.GetTurnPlayer() and bit.band(ph,PHASE_MAIN2+PHASE_END)==0
end
-- 效果处理：创建一个影响全场的永续效果，令对方玩家在这个回合内不能进行攻击宣言。
function c36361633.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合对方不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(0,1)
	-- 将创建的永续效果注册到决斗中，以当前玩家tp作为效果的持有者，使该效果开始适用。
	Duel.RegisterEffect(e1,tp)
end
