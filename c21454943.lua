--サイコ・コマンダー
-- 效果：
-- 自己场上存在的念动力族怪兽进行战斗的场合，那个伤害步骤时支付100的倍数的基本分才能发动（最多500）。直到这个回合的结束阶段时，进行战斗的1只对方怪兽的攻击力·守备力下降支付的数值。
function c21454943.initial_effect(c)
	-- 自己场上存在的念动力族怪兽进行战斗的场合，那个伤害步骤时支付100的倍数的基本分才能发动（最多500）。直到这个回合的结束阶段时，进行战斗的1只对方怪兽的攻击力·守备力下降支付的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetDescription(aux.Stringid(21454943,0))  --"攻守下降"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c21454943.condition)
	e1:SetCost(c21454943.cost)
	e1:SetTarget(c21454943.target)
	e1:SetOperation(c21454943.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：仅在伤害步骤且尚未进行伤害计算时，根据攻击怪兽的控制者是自己还是对方，检验我方场上的念动力族怪兽与对方怪兽是否都表侧表示且与战斗相关，满足条件则记录对应的对方怪兽并返回true。
function c21454943.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local phase=Duel.GetCurrentPhase()
	-- 若当前不是伤害步骤，或已经进行过伤害计算，则不满足发动时点，效果不能发动。
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 取得当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 取得当前战斗的被攻击怪兽（直接攻击时可能为nil）。
	local d=Duel.GetAttackTarget()
	if a:IsControler(tp) then
		e:SetLabelObject(d)
		return a:IsFaceup() and a:IsRace(RACE_PSYCHO) and a:IsRelateToBattle() and d and d:IsFaceup() and d:IsRelateToBattle()
	else
		e:SetLabelObject(a)
		return d and d:IsFaceup() and d:IsRace(RACE_PSYCHO) and d:IsRelateToBattle() and a and a:IsFaceup() and a:IsRelateToBattle()
	end
end
-- 代价判定：取得记录的战斗对象，检查是否能支付100LP、是否本回合未发动过该效果、对象攻击力或守备力是否在100以上，这些条件都满足时才允许发动。
function c21454943.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	-- 检查玩家可以支付100LP且该卡本回合没有发动过此效果的flag。
	if chk==0 then return Duel.CheckLPCost(tp,100,true) and e:GetHandler():GetFlagEffect(21454943)==0
						and (bc:IsAttackAbove(100) or bc:IsDefenseAbove(100)) end
	-- lp取当前LP减1，作为可支付的最大基本分，保证支付后LP不会降到0。
	local lp=Duel.GetLP(tp)-1
	local alp=100
	local maxpay=bc:GetAttack()
	local def=bc:GetDefense()
	if maxpay<def then maxpay=def end
	if maxpay<lp then lp=maxpay end
	-- 显示“请选择要支付的基本分”的提示信息，供玩家选择。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(21454943,1))  --"请选择要支付的基本分"
	-- 若可支付上限达到500，则让玩家宣言100/200/300/400/500中的一个数值作为支付的基本分。
	if lp>=500 then alp=Duel.AnnounceNumber(tp,100,200,300,400,500)
	-- 若可支付上限为400～499，则选项为100/200/300/400。
	elseif lp>=400 then alp=Duel.AnnounceNumber(tp,100,200,300,400)
	-- 若可支付上限为300～399，则选项为100/200/300。
	elseif lp>=300 then alp=Duel.AnnounceNumber(tp,100,200,300)
	-- 若可支付上限为200～299，则选项为100/200。
	elseif lp>=200 then alp=Duel.AnnounceNumber(tp,100,200)
	end
	-- 实际支付所选数值的基本分作为发动代价。
	Duel.PayLPCost(tp,alp,true)
	e:SetLabel(alp)
	e:GetHandler():RegisterFlagEffect(21454943,RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 效果对象选择：将之前记录的进行战斗的对方怪兽作为取对象目标，且该目标必须能成为效果的对象。
function c21454943.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=e:GetLabelObject()
	if chkc then return chkc==tc end
	if chk==0 then return tc:IsCanBeEffectTarget(e) end
	-- 将当前处理连锁的效果对象设定为tc，使其成为取对象的效果目标。
	Duel.SetTargetCard(tc)
end
-- 效果处理：若目标怪兽仍存在、与效果相关且仍由对方控制，则给它赋予攻击力和守备力下降指定数值的效果，持续到结束阶段。
function c21454943.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的目标怪兽（那只对方战斗怪兽）。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsControler(1-tp) then return end
	-- 直到这个回合的结束阶段时，进行战斗的1只对方怪兽的攻击力下降支付的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(-e:GetLabel())
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	tc:RegisterEffect(e2)
end
