--窮鼠の進撃
-- 效果：
-- 自己场上存在的3星以下的通常怪兽进行战斗的场合，那个伤害步骤时支付100的倍数的基本分才能发动。直到这个回合的结束阶段时，进行战斗的1只对方怪兽的攻击力下降支付的数值。
function c84389640.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上存在的3星以下的通常怪兽进行战斗的场合，那个伤害步骤时支付100的倍数的基本分才能发动。直到这个回合的结束阶段时，进行战斗的1只对方怪兽的攻击力下降支付的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetDescription(aux.Stringid(84389640,0))  --"攻击下降"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c84389640.condition)
	e2:SetCost(c84389640.cost)
	e2:SetTarget(c84389640.target)
	e2:SetOperation(c84389640.operation)
	c:RegisterEffect(e2)
end
-- 检查是否在伤害步骤（未计算伤害前），且自己场上有3星以下的通常怪兽与对方怪兽进行战斗
function c84389640.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local phase=Duel.GetCurrentPhase()
	-- 必须在伤害步骤，且不能是已经计算完伤害的时点
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	e:SetLabelObject(d)
	return a:IsFaceup() and a:IsLevelBelow(3) and a:IsType(TYPE_NORMAL) and a:IsRelateToBattle()
		and d:IsFaceup() and d:IsRelateToBattle()
end
-- 检查发动条件与代价：确保此效果在本次伤害步骤中未发动过，且玩家有足够的基本分，且对方怪兽的攻击力不低于100
function c84389640.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认该卡在当前伤害步骤未注册过标识，且玩家能够支付至少100基本分
	if chk==0 then return e:GetHandler():GetFlagEffect(84389640)==0 and Duel.CheckLPCost(tp,100,true)
		and e:GetLabelObject():IsAttackAbove(100) end
	-- 获取发动玩家当前的生命值
	local lp=Duel.GetLP(tp)
	local atk=e:GetLabelObject():GetAttack()
	local maxc=math.min(atk,lp,25500)
	maxc=math.floor(maxc/100)*100
	local t={}
	for i=1,maxc/100 do
		t[i]=i*100
	end
	-- 向玩家发送提示信息，要求选择要支付的基本分
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(84389640,1))  --"请选择要支付的基本分"
	-- 让玩家宣言一个要支付的基本分数值（从可选的100的倍数列表中选择）
	local pay=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 扣除玩家宣言的对应数值的基本分
	Duel.PayLPCost(tp,pay,true)
	e:SetLabel(pay)
	e:GetHandler():RegisterFlagEffect(84389640,RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 将进行战斗的对方怪兽确定为效果的对象
function c84389640.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=e:GetLabelObject()
	if chkc then return chkc==tc end
	if chk==0 then return tc:IsCanBeEffectTarget(e) end
	-- 将进行战斗的对方怪兽设置为效果的目标
	Duel.SetTargetCard(tc)
end
-- 执行效果：使目标对方怪兽的攻击力下降支付的数值，直到回合结束阶段
function c84389640.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽（即进行战斗的对方怪兽）
	local bc=Duel.GetFirstTarget()
	if not e:GetHandler():IsRelateToEffect(e) or not bc or not bc:IsRelateToEffect(e) or not bc:IsControler(1-tp) then return end
	-- 直到这个回合的结束阶段时，进行战斗的1只对方怪兽的攻击力下降支付的数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetOwnerPlayer(tp)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(e:GetLabel()*-1)
	bc:RegisterEffect(e1)
end
