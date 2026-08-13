--冥王の咆哮
-- 效果：
-- 自己场上存在的恶魔族怪兽进行战斗的场合，那个伤害步骤时支付100的倍数的基本分发动。直到这个回合的结束阶段时，进行战斗的1只对方怪兽的攻击力·守备力下降支付的数值。
function c41925941.initial_effect(c)
	-- 自己场上存在的恶魔族怪兽进行战斗的场合，那个伤害步骤时支付100的倍数的基本分发动。直到这个回合的结束阶段时，进行战斗的1只对方怪兽的攻击力·守备力下降支付的数值。
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
-- 发动条件处理：仅当处于伤害步骤且伤害计算前，并且自己场上有表侧表示恶魔族怪兽正在进行战斗（无论是攻击方还是被攻击方）时满足；同时将对方参与战斗的怪兽记录到效果标签中。
function c41925941.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local phase=Duel.GetCurrentPhase()
	-- 若当前不是伤害步骤或伤害已经计算完毕，则本效果不能发动。
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 取得当前攻击怪兽。
	local a=Duel.GetAttacker()
	-- 取得被攻击的怪兽（若没有攻击对象则为nil）。
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
-- 发动代价处理：玩家从100的倍数中宣言一个LP数值进行支付；可支付上限取己方当前LP、对方怪兽攻击力/守备力中的较高者、25500三者的最小值并向下取整到百位；支付后将数值记录在效果标签中，用于后续下降攻击力/守备力。
function c41925941.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	-- 代价检查：己方至少能支付100LP，且对方战斗怪兽的攻击力或守备力至少为100，否则不能发动。
	if chk==0 then return Duel.CheckLPCost(tp,100,true) and (bc:IsAttackAbove(100) or bc:IsDefenseAbove(100)) end
	-- 以己方当前LP作为可支付LP上限的初始值。
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
	-- 让玩家从所有100的倍数可选项中宣言一个数值，作为本次支付的LP。
	local cost=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 实际支付宣言的LP数值。
	Duel.PayLPCost(tp,cost,true)
	e:SetLabel(cost)
end
-- 效果对象处理：无需另行选择卡片，直接将效果发动时记录的对方战斗怪兽设置为效果对象。
function c41925941.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return true end
	-- 将暂存的对方战斗怪兽设置为当前连锁的处理对象。
	Duel.SetTargetCard(tc)
end
-- 效果处理：若对象怪兽仍与效果相关且是对方怪兽，则赋予其攻击力·守备力下降已支付数值的持续效果，直到结束阶段；下降攻击力和守备力分别通过两个效果实现。
function c41925941.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理的对象怪兽。
	local bc=Duel.GetFirstTarget()
	local val=e:GetLabel()
	if not bc or not bc:IsRelateToEffect(e) or not bc:IsControler(1-tp) then return end
	-- 直到这个回合的结束阶段时，进行战斗的1只对方怪兽的攻击力·守备力下降支付的数值。
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
