--BF－尖鋭のボーラ
-- 效果：
-- 把墓地存在的这张卡从游戏中除外，选择自己场上表侧表示存在的1只名字带有「黑羽」的怪兽发动。这个回合选择的怪兽攻击的场合，那次攻击发生的对自己的战斗伤害变成0，选择的怪兽不会被战斗破坏，进行战斗的对方怪兽在伤害计算后破坏。
function c16516630.initial_effect(c)
	-- 创建此卡的起动效果，效果描述为附加能力，类型为起动效果，需要选择对象，发动位置为墓地，条件为回合主要阶段1，费用为将此卡除外，目标为己方场上表侧表示存在的1只名字带有「黑羽」的怪兽，效果处理为执行operation函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16516630,0))  --"附加能力"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c16516630.condition)
	-- 将此卡从游戏中除外作为发动此效果的费用
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c16516630.target)
	e1:SetOperation(c16516630.operation)
	c:RegisterEffect(e1)
end
-- 判断当前是否为回合主要阶段1
function c16516630.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段必须为回合主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 过滤条件：对象必须为表侧表示且种族为黑羽
function c16516630.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
-- 设置效果目标，选择己方场上表侧表示存在的1只名字带有「黑羽」的怪兽
function c16516630.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c16516630.filter(chkc) end
	-- 检查是否有满足条件的怪兽存在
	if chk==0 then return Duel.IsExistingTarget(c16516630.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c16516630.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行效果处理，为选择的怪兽设置不会被战斗破坏、不会受到战斗伤害，并在战斗后破坏对方怪兽
function c16516630.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	-- 为选择的怪兽设置不会被战斗破坏的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	tc:RegisterEffect(e2)
	-- 为选择的怪兽设置战斗时不会受到战斗伤害的效果，并在战斗结束后破坏对方怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(c16516630.desop)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e3)
end
-- 当怪兽进行战斗时触发的效果处理函数
function c16516630.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的对方怪兽
	local d=Duel.GetAttackTarget()
	-- 若对方怪兽存在且不是自身，则将其破坏
	if d and d~=e:GetHandler() then Duel.Destroy(d,REASON_EFFECT) end
end
