--光の護封霊剣
-- 效果：
-- ①：对方怪兽的攻击宣言时1次，支付1000基本分才能发动。那次攻击无效。
-- ②：对方回合把墓地的这张卡除外才能发动。这个回合，对方怪兽不能直接攻击。
function c78625592.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方怪兽的攻击宣言时1次，支付1000基本分才能发动。那次攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78625592,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c78625592.condition)
	e2:SetCost(c78625592.cost)
	e2:SetOperation(c78625592.operation)
	c:RegisterEffect(e2)
	-- ②：对方回合把墓地的这张卡除外才能发动。这个回合，对方怪兽不能直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(78625592,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_ATTACK)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(c78625592.grcondition)
	-- 设置效果的发动代价为把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetOperation(c78625592.groperation)
	c:RegisterEffect(e3)
end
-- 定义效果①的发动条件函数
function c78625592.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方，即在对方怪兽攻击宣言时才能发动
	return tp~=Duel.GetTurnPlayer()
end
-- 定义效果①的发动代价函数
function c78625592.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测模式，则检查发动玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除发动玩家1000基本分作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 定义效果①的效果处理函数
function c78625592.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前的攻击
	Duel.NegateAttack()
end
-- 定义效果②的发动条件函数
function c78625592.grcondition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合，且处于可以进行战斗相关操作的时点
	return Duel.GetTurnPlayer()~=tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 定义效果②的效果处理函数
function c78625592.groperation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方怪兽不能直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能直接攻击的限制效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
