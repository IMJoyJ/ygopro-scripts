--冥王の咆哮
-- 效果：
-- 自己场上存在的恶魔族怪兽进行战斗的场合，那个伤害步骤时支付100的倍数的基本分发动。直到这个回合的结束阶段时，进行战斗的1只对方怪兽的攻击力·守备力下降支付的数值。
function c41925941.initial_effect(c)
	-- 创建一张永续效果，用于在自由时点发动，属于攻击变化类别，提示在伤害步骤时点发动，且只能在伤害步骤发动，条件为c41925941.condition，费用为c41925941.cost，目标为c41925941.target，效果处理为c41925941.operation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c41925941.condition)
	e1:SetCost(c41925941.cost)
	e1:SetTarget(c41925941.target)
	e1:SetOperation(c41925941.operation)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：当前阶段为伤害步骤且未计算战斗伤害，攻击怪兽和防守怪兽存在且处于战斗状态，且攻击方或防守方为当前玩家的恶魔族怪兽
function c41925941.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local phase=Duel.GetCurrentPhase()
	-- 若当前阶段不是伤害步骤或战斗伤害已计算，则返回false
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	if a:IsControler(tp) then
		e:SetLabelObject(d)
		return a:IsFaceup() and a:IsRace(RACE_FIEND) and a:IsRelateToBattle()
			and d and d:IsFaceup() and d:IsRelateToBattle()
	elseif d and d:IsControler(tp) then
		e:SetLabelObject(a)
		return d:IsFaceup() and d:IsRace(RACE_FIEND) and d:IsRelateToBattle()
			and a and a:IsFaceup() and a:IsRelateToBattle()
	end
end
-- 定义费用函数：检查玩家是否能支付100点基本分并确认目标怪兽攻击力或守备力是否至少为100点
function c41925941.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	-- 若为检查阶段（chk==0），则返回是否能支付100点基本分且目标怪兽攻击力或守备力至少为100点
	if chk==0 then return Duel.CheckLPCost(tp,100,true) and (bc:IsAttackAbove(100) or bc:IsDefenseAbove(100)) end
	-- 获取当前玩家的基本分
	local maxc=Duel.GetLP(tp)
	local maxpay=bc:GetAttack()
	local def=bc:GetDefense()
	if maxpay<def then maxpay=def end
	if maxpay<maxc then maxc=maxpay end
	if maxc>25500 then maxc=25500 end
	maxc=math.floor(maxc/100)*100
	local t={}
	for i=1,maxc/100 do
		t[i]=i*100
	end
	-- 让当前玩家宣言一个可支付的基本分数值（以100为单位）
	local cost=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 支付宣言的基本分
	Duel.PayLPCost(tp,cost,true)
	e:SetLabel(cost)
end
-- 定义目标函数：设置目标怪兽为之前记录的怪兽
function c41925941.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return true end
	-- 设置当前连锁的目标为指定怪兽
	Duel.SetTargetCard(tc)
end
-- 定义效果处理函数：获取目标怪兽并应用攻击力和守备力下降效果
function c41925941.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local bc=Duel.GetFirstTarget()
	local val=e:GetLabel()
	if not bc or not bc:IsRelateToEffect(e) or not bc:IsControler(1-tp) then return end
	-- 创建一个攻击力下降的效果，数值为支付的基本分，持续到结束阶段
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-val)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	bc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	bc:RegisterEffect(e2)
end
