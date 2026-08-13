--銀幕の鏡壁
-- 效果：
-- 这张卡的控制者在每次自己准备阶段支付2000基本分。或者不支付基本分让这张卡破坏。
-- ①：只要这张卡在魔法与陷阱区域存在，对方的攻击怪兽的攻击力变成一半。
function c22359980.initial_effect(c)
	-- ①：只要这张卡在魔法与陷阱区域存在，对方的攻击怪兽的攻击力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DAMAGE_STEP)
	-- 设置发动条件：当前不是伤害步骤，或处于伤害步骤且尚未进行伤害计算时才能发动，即伤害步骤内只能在伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c22359980.target)
	e1:SetOperation(c22359980.operation)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，对方的攻击怪兽的攻击力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c22359980.operation)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，对方的攻击怪兽的攻击力变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_ATTACK_FINAL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c22359980.atktg)
	e3:SetValue(c22359980.atkval)
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e1:SetLabelObject(g)
	e2:SetLabelObject(g)
	e3:SetLabelObject(g)
	-- 这张卡的控制者在每次自己准备阶段支付2000基本分。或者不支付基本分让这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c22359980.mtcon)
	e4:SetOperation(c22359980.mtop)
	c:RegisterEffect(e4)
end
-- 发动时的目标处理：不取对象，仅判定可以发动（chk==0时返回true）；同时清空LabelObject中记录的怪兽，为新一轮攻击宣言记录做准备。
function c22359980.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetLabelObject():Clear()
end
-- 攻击宣言时的处理：将攻击怪兽中满足“对方场上表侧表示且在怪兽区”条件的加入LabelObject，并给它放置22359980标识，以标记该怪兽应受减半攻击力效果影响。
function c22359980.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言的怪兽。
	local a=Duel.GetAttacker()
	if a and a:IsControler(1-tp) and a:IsFaceup() and a:IsLocation(LOCATION_MZONE) then
		e:GetLabelObject():AddCard(a)
		if a:GetFlagEffect(22359980)==0 then
			a:RegisterFlagEffect(22359980,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
end
-- 永续效果的过滤条件：目标怪兽必须带有22359980标识且存在于LabelObject中，即必须是本卡效果记录过的对方攻击怪兽。
function c22359980.atktg(e,c)
	return c:GetFlagEffect(22359980)~=0 and e:GetLabelObject():IsContains(c)
end
-- 计算攻击力数值：将该怪兽的当前攻击力减半并向上取整，令其攻击力变成一半。
function c22359980.atkval(e,c)
	return math.ceil(c:GetAttack()/2)
end
-- 维持费用的触发条件：当前回合玩家是这张卡的控制者，即只有在自己准备阶段才执行维持处理。
function c22359980.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者（tp），用于限定自己准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 维持费用的处理：在自己准备阶段，若控制者能支付2000基本分且选择支付，则支付2000LP；否则这张卡作为费用被破坏。
function c22359980.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查控制者是否能支付2000基本分，并弹窗询问是否支付2000基本分维持「银幕之镜壁」。
	if Duel.CheckLPCost(tp,2000) and Duel.SelectYesNo(tp,aux.Stringid(22359980,0)) then  --"是否要支付2000基本分维持「银幕之镜壁」？"
		-- 控制者支付2000基本分，作为维持这张卡的代价。
		Duel.PayLPCost(tp,2000)
	else
		-- 控制者不支付基本分时，以规则代价方式将这张卡自身破坏。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
