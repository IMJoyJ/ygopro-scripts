--メンタルプロテクター
-- 效果：
-- 这张卡的控制者在每次自己的准备阶段支付500基本分。这个时候不支付500基本分的场合这张卡破坏。只要这张卡在场上表侧表示存在，念动力族怪兽以外的攻击力2000以下的怪兽不能攻击宣言。
function c85060248.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，念动力族怪兽以外的攻击力2000以下的怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c85060248.atktarget)
	c:RegisterEffect(e2)
	-- 这张卡的控制者在每次自己的准备阶段支付500基本分。这个时候不支付500基本分的场合这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c85060248.mtcon)
	e3:SetOperation(c85060248.mtop)
	c:RegisterEffect(e3)
end
-- 过滤出非念动力族且攻击力在2000以下的怪兽作为不能攻击宣言的对象
function c85060248.atktarget(e,c)
	return not c:IsRace(RACE_PSYCHO) and c:IsAttackBelow(2000)
end
-- 判断是否在自己的准备阶段，用于触发维持代价效果
function c85060248.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 处理准备阶段支付500基本分维持或不支付将这张卡破坏的效果
function c85060248.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能支付500基本分并询问玩家是否选择支付
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(85060248,0)) then  --"是否要支付500基本分维持「精神防护者」？"
		-- 让玩家支付500基本分
		Duel.PayLPCost(tp,500)
	else
		-- 将这张卡因未支付维持代价而破坏
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
