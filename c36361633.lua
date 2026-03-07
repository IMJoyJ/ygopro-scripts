--威嚇する咆哮
-- 效果：
-- ①：这个回合对方不能攻击宣言。
function c36361633.initial_effect(c)
	-- 效果原文内容：①：这个回合对方不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0xc)
	e1:SetCondition(c36361633.condition)
	e1:SetOperation(c36361633.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断是否满足发动条件，即当前回合玩家不是使用者且不在主要阶段2或结束阶段。
function c36361633.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 规则层面作用：返回值为真表示当前不是回合玩家且不在主要阶段2或结束阶段。
	return tp~=Duel.GetTurnPlayer() and bit.band(ph,PHASE_MAIN2+PHASE_END)==0
end
-- 规则层面作用：设置卡片效果发动时执行的操作，创建一个影响对方的不能攻击宣言效果。
function c36361633.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：这个回合对方不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(0,1)
	-- 规则层面作用：将效果注册给对方玩家，使其在本回合无法进行攻击宣言。
	Duel.RegisterEffect(e1,tp)
end
