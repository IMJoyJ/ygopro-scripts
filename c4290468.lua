--スプレンディッド・ローズ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 1回合1次，可以把自己墓地存在的1只植物族怪兽从游戏中除外，对方场上表侧表示存在的1只怪兽的攻击力直到这个回合的结束阶段时变成一半数值。此外，这张卡攻击的那次战斗阶段中，可以把自己墓地存在的1只植物族怪兽从游戏中除外，这张卡的攻击力直到结束阶段时变成一半数值，只有1次再攻击。
function c4290468.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，可以把自己墓地存在的1只植物族怪兽从游戏中除外，对方场上表侧表示存在的1只怪兽的攻击力直到这个回合的结束阶段时变成一半数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4290468,0))  --"攻击下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c4290468.atkcost)
	e1:SetTarget(c4290468.atktg)
	e1:SetOperation(c4290468.atkop)
	c:RegisterEffect(e1)
	-- 此外，这张卡攻击的那次战斗阶段中，可以把自己墓地存在的1只植物族怪兽从游戏中除外，这张卡的攻击力直到结束阶段时变成一半数值，只有1次再攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4290468,1))  --"再次攻击"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c4290468.dacon)
	e2:SetCost(c4290468.dacost)
	e2:SetOperation(c4290468.daop)
	c:RegisterEffect(e2)
end
-- 定义用于判断是否为植物族且可作为除外代价的怪兽的过滤函数
function c4290468.costfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemoveAsCost()
end
-- 效果处理函数，检查是否满足除外植物族怪兽的条件并选择除外
function c4290468.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外植物族怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c4290468.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张墓地中的植物族怪兽
	local g=Duel.SelectMatchingCard(tp,c4290468.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的植物族怪兽从游戏中除外作为效果代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理函数，检查是否满足选择对方场上表侧表示怪兽的条件并选择目标
function c4290468.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查是否满足选择对方场上表侧表示怪兽的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择对方场上表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上表侧表示的1只怪兽作为目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数，将目标怪兽的攻击力变为一半
function c4290468.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 将目标怪兽的攻击力设置为原来的一半数值
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		tc:RegisterEffect(e1)
	end
end
-- 判断是否满足再次攻击效果发动的条件
function c4290468.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为战斗阶段
	return Duel.GetCurrentPhase()==PHASE_BATTLE_STEP and e:GetHandler():GetAttackedCount()~=0
		-- 此卡已进行过攻击且当前无攻击怪兽，且当前无连锁处理
		and Duel.GetAttacker()==nil and Duel.GetCurrentChain()==0
end
-- 再次攻击效果处理函数，检查是否满足除外植物族怪兽的条件并选择除外
function c4290468.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外植物族怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c4290468.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张墓地中的植物族怪兽
	local g=Duel.SelectMatchingCard(tp,c4290468.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的植物族怪兽从游戏中除外作为效果代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 再次攻击效果处理函数，将自身攻击力变为一半并获得一次额外攻击
function c4290468.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 将自身攻击力设置为原来的一半数值
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(math.ceil(c:GetAttack()/2))
	c:RegisterEffect(e1)
	-- 使自身获得一次额外攻击机会
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
