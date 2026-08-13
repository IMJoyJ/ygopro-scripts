--BF－尖鋭のボーラ
-- 效果：
-- 把墓地存在的这张卡从游戏中除外，选择自己场上表侧表示存在的1只名字带有「黑羽」的怪兽发动。这个回合选择的怪兽攻击的场合，那次攻击发生的对自己的战斗伤害变成0，选择的怪兽不会被战斗破坏，进行战斗的对方怪兽在伤害计算后破坏。
function c16516630.initial_effect(c)
	-- 把墓地存在的这张卡从游戏中除外，选择自己场上表侧表示存在的1只名字带有「黑羽」的怪兽发动。这个回合选择的怪兽攻击的场合，那次攻击发生的对自己的战斗伤害变成0，选择的怪兽不会被战斗破坏，进行战斗的对方怪兽在伤害计算后破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16516630,0))  --"附加能力"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c16516630.condition)
	-- 设置效果的发动代价：把墓地中的这张卡从游戏中除外。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c16516630.target)
	e1:SetOperation(c16516630.operation)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：效果只能在主要阶段1发动。
function c16516630.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段是否为主要阶段1，若是才可发动。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 定义对象选择过滤器：选择自己场上表侧表示且卡名属于「黑羽」系列的怪兽。
function c16516630.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
-- 定义目标选择函数：连锁确认时校验对象是否合法；发动确认时检查存在合法对象；然后弹出提示并让玩家选择自己场上表侧表示的名字带有「黑羽」的1只怪兽。
function c16516630.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c16516630.filter(chkc) end
	-- 效果发动时报“检查”：确认自己场上存在至少1只满足条件的表侧表示「黑羽」怪兽，否则无法发动。
	if chk==0 then return Duel.IsExistingTarget(c16516630.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示“请选择表侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上表侧表示的名字带有「黑羽」的1只怪兽作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,c16516630.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义效果处理：取得目标怪兽并确认其仍为表侧且与效果关联后，给该怪兽赋予“本回合不会被战斗破坏”、“对自己的战斗伤害变为0”以及“伤害计算后破坏对方怪兽”的效果。
function c16516630.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	-- 选择的怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	tc:RegisterEffect(e2)
	-- 这个回合选择的怪兽攻击的场合，进行战斗的对方怪兽在伤害计算后破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(c16516630.desop)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e3)
end
-- 定义伤害计算后的处理函数：在选择的怪兽进行战斗的伤害计算后，将与之战斗的对方怪兽破坏。
function c16516630.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的攻击目标怪兽（即对方那只进行战斗的怪兽）。
	local d=Duel.GetAttackTarget()
	-- 若攻击目标存在且不是该效果所属的怪兽（即我方选择的「黑羽」怪兽），则将其以效果破坏。
	if d and d~=e:GetHandler() then Duel.Destroy(d,REASON_EFFECT) end
end
