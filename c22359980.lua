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
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c22359980.target)
	e1:SetOperation(c22359980.operation)
	c:RegisterEffect(e1)
	-- 攻击宣言时，记录本次攻击的怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c22359980.operation)
	c:RegisterEffect(e2)
	-- 对方的攻击怪兽的攻击力变成一半。
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
-- 初始化效果目标，清空记录的攻击怪兽。
function c22359980.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetLabelObject():Clear()
end
-- 记录当前攻击怪兽到效果标签对象中，并为其添加标记效果。
function c22359980.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽。
	local a=Duel.GetAttacker()
	if a and a:IsControler(1-tp) and a:IsFaceup() and a:IsLocation(LOCATION_MZONE) then
		e:GetLabelObject():AddCard(a)
		if a:GetFlagEffect(22359980)==0 then
			a:RegisterFlagEffect(22359980,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
end
-- 判断目标怪兽是否为攻击怪兽且已记录。
function c22359980.atktg(e,c)
	return c:GetFlagEffect(22359980)~=0 and e:GetLabelObject():IsContains(c)
end
-- 将目标怪兽的攻击力设为原来的一半。
function c22359980.atkval(e,c)
	return math.ceil(c:GetAttack()/2)
end
-- 判断是否为当前回合玩家的准备阶段。
function c22359980.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为效果持有者。
	return Duel.GetTurnPlayer()==tp
end
-- 处理准备阶段的支付或破坏选择。
function c22359980.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能支付2000基本分并询问是否支付。
	if Duel.CheckLPCost(tp,2000) and Duel.SelectYesNo(tp,aux.Stringid(22359980,0)) then  --"是否要支付2000基本分维持「银幕之镜壁」？"
		-- 支付2000基本分。
		Duel.PayLPCost(tp,2000)
	else
		-- 因未支付基本分而破坏此卡。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
