--サイコ・コマンダー
-- 效果：
-- 自己场上存在的念动力族怪兽进行战斗的场合，那个伤害步骤时支付100的倍数的基本分才能发动（最多500）。直到这个回合的结束阶段时，进行战斗的1只对方怪兽的攻击力·守备力下降支付的数值。
function c21454943.initial_effect(c)
	-- 效果原文内容：自己场上存在的念动力族怪兽进行战斗的场合，那个伤害步骤时支付100的倍数的基本分才能发动（最多500）。直到这个回合的结束阶段时，进行战斗的1只对方怪兽的攻击力·守备力下降支付的数值。
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
-- 效果作用：判断是否满足发动条件，即当前处于伤害步骤且未计算战斗伤害，同时攻击怪兽或防守怪兽为念动力族且处于战斗状态。
function c21454943.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前游戏阶段
	local phase=Duel.GetCurrentPhase()
	-- 效果作用：若当前阶段不是伤害步骤或战斗伤害已计算，则无法发动效果
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 效果作用：获取当前攻击怪兽
	local a=Duel.GetAttacker()
	-- 效果作用：获取当前防守怪兽
	local d=Duel.GetAttackTarget()
	if a:IsControler(tp) then
		e:SetLabelObject(d)
		return a:IsFaceup() and a:IsRace(RACE_PSYCHO) and a:IsRelateToBattle() and d and d:IsFaceup() and d:IsRelateToBattle()
	else
		e:SetLabelObject(a)
		return d and d:IsFaceup() and d:IsRace(RACE_PSYCHO) and d:IsRelateToBattle() and a and a:IsFaceup() and a:IsRelateToBattle()
	end
end
-- 效果作用：判断是否满足支付基本分的条件，包括检查玩家是否有足够的基本分、该卡是否已发动过此效果、以及目标怪兽攻击力或守备力是否至少为100点。
function c21454943.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	-- 效果作用：检查玩家是否能支付100点基本分，并确认该卡未在本回合发动过此效果
	if chk==0 then return Duel.CheckLPCost(tp,100,true) and e:GetHandler():GetFlagEffect(21454943)==0
						and (bc:IsAttackAbove(100) or bc:IsDefenseAbove(100)) end
	-- 效果作用：获取玩家当前基本分并减去1
	local lp=Duel.GetLP(tp)-1
	local alp=100
	local maxpay=bc:GetAttack()
	local def=bc:GetDefense()
	if maxpay<def then maxpay=def end
	if maxpay<lp then lp=maxpay end
	-- 效果作用：提示玩家选择要支付的基本分数量
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(21454943,1))  --"请选择要支付的基本分"
	-- 效果作用：当玩家基本分大于等于500时，允许其宣言100、200、300、400或500点基本分
	if lp>=500 then alp=Duel.AnnounceNumber(tp,100,200,300,400,500)
	-- 效果作用：当玩家基本分大于等于400时，允许其宣言100、200、300或400点基本分
	elseif lp>=400 then alp=Duel.AnnounceNumber(tp,100,200,300,400)
	-- 效果作用：当玩家基本分大于等于300时，允许其宣言100、200或300点基本分
	elseif lp>=300 then alp=Duel.AnnounceNumber(tp,100,200,300)
	-- 效果作用：当玩家基本分大于等于200时，允许其宣言100或200点基本分
	elseif lp>=200 then alp=Duel.AnnounceNumber(tp,100,200)
	end
	-- 效果作用：支付宣言的基本分
	Duel.PayLPCost(tp,alp,true)
	e:SetLabel(alp)
	e:GetHandler():RegisterFlagEffect(21454943,RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 效果作用：设置目标怪兽为进行战斗的对方怪兽
function c21454943.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=e:GetLabelObject()
	if chkc then return chkc==tc end
	if chk==0 then return tc:IsCanBeEffectTarget(e) end
	-- 效果作用：将目标怪兽设置为连锁处理对象
	Duel.SetTargetCard(tc)
end
-- 效果作用：执行效果，将目标怪兽的攻击力和守备力下降支付的基本分数值
function c21454943.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsControler(1-tp) then return end
	-- 效果原文内容：直到这个回合的结束阶段时，进行战斗的1只对方怪兽的攻击力·守备力下降支付的数值。
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
