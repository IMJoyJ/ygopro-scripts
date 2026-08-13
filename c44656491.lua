--平和の使者
-- 效果：
-- 场上表侧表示存在的攻击力1500以上的怪兽不能攻击宣言。这张卡的控制者在每次自己的准备阶段支付100基本分。或者不支付100基本分让这张卡破坏。
function c44656491.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的攻击力1500以上的怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c44656491.atktarget)
	c:RegisterEffect(e2)
	-- 这张卡的控制者在每次自己的准备阶段支付100基本分。或者不支付100基本分让这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c44656491.mtcon)
	e3:SetOperation(c44656491.mtop)
	c:RegisterEffect(e3)
end
-- 作为不能攻击宣言的过滤条件：筛选出攻击力1500以上的怪兽（含表侧表示限制，因为该永续效果只影响场上表侧表示怪兽）。
function c44656491.atktarget(e,c)
	return c:GetAttack()>=1500
end
-- 判断效果触发时是否为这张卡控制者自己的准备阶段。
function c44656491.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家等于这张卡的控制者（tp）时条件成立，即正处于控制者的准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 在控制者的准备阶段，先检查能否支付100基本分并让控制者选择；若选择支付则支付100基本分，否则将这张卡破坏。
function c44656491.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查控制者能否支付100基本分，并弹出是否支付100基本分维持这张卡的确认提示。
	if Duel.CheckLPCost(tp,100) and Duel.SelectYesNo(tp,aux.Stringid(44656491,0)) then  --"是否要支付100基本分维持「和平使者」？"
		-- 控制者支付100基本分作为维持费用。
		Duel.PayLPCost(tp,100)
	else
		-- 控制者不支付维持费用时，以代价形式将这张卡破坏。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
