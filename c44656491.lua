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
-- 判断目标怪兽是否攻击力大于等于1500
function c44656491.atktarget(e,c)
	return c:GetAttack()>=1500
end
-- 判断是否为当前回合玩家
function c44656491.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 执行准备阶段的支付或破坏操作
function c44656491.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能支付100基本分并询问是否支付
	if Duel.CheckLPCost(tp,100) and Duel.SelectYesNo(tp,aux.Stringid(44656491,0)) then  --"是否要支付100基本分维持「和平使者」？"
		-- 支付100基本分
		Duel.PayLPCost(tp,100)
	else
		-- 因支付代价不足而破坏此卡
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
