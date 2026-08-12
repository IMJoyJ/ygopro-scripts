--通行税
-- 效果：
-- 双方玩家若不支付500基本分，则不能攻击宣言。
function c82003859.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 双方玩家若不支付500基本分，则不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ATTACK_COST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCost(c82003859.atcost)
	e2:SetOperation(c82003859.atop)
	c:RegisterEffect(e2)
	-- 双方玩家若不支付500基本分，则不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_FLAG_EFFECT+82003859)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	c:RegisterEffect(e3)
end
-- 检查进行攻击宣言的玩家是否能够支付因场上「通行税」数量而累计的基本分代价
function c82003859.atcost(e,c,tp)
	-- 获取当前玩家受场上「通行税」效果影响的数量（用于计算累计需要支付的基本分）
	local ct=Duel.GetFlagEffect(tp,82003859)
	-- 检查玩家当前的基本分是否足够支付累计的代价（数量 × 500）
	return Duel.CheckLPCost(tp,ct*500)
end
-- 攻击宣言时，玩家支付基本分的操作
function c82003859.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 扣除进行攻击宣言的玩家500点基本分
	Duel.PayLPCost(tp,500)
end
