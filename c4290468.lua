--スプレンディッド・ローズ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 1回合1次，可以把自己墓地存在的1只植物族怪兽从游戏中除外，对方场上表侧表示存在的1只怪兽的攻击力直到这个回合的结束阶段时变成一半数值。此外，这张卡攻击的那次战斗阶段中，可以把自己墓地存在的1只植物族怪兽从游戏中除外，这张卡的攻击力直到结束阶段时变成一半数值，只有1次再攻击。
function c4290468.initial_effect(c)
	-- 为这张卡添加同调召唤手续：作为同调素材时，需要1只调整以外的怪兽和1只以上调整以外的怪兽（即调整＋调整以外的怪兽1只以上）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- “1回合1次，可以把自己墓地存在的1只植物族怪兽从游戏中除外，对方场上表侧表示存在的1只怪兽的攻击力直到这个回合的结束阶段时变成一半数值。”
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
	-- “此外，这张卡攻击的那次战斗阶段中，可以把自己墓地存在的1只植物族怪兽从游戏中除外，这张卡的攻击力直到结束阶段时变成一半数值，只有1次再攻击。”
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
-- 定义用于选择代价卡的过滤条件：该卡必须为植物族怪兽，并且可以作为代价从墓地除外。
function c4290468.costfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemoveAsCost()
end
-- 第一个效果的代价处理：检查自己墓地是否存在符合条件的植物族怪兽，存在则让玩家选择1张并表侧除外作为发动代价。
function c4290468.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价判定阶段：确认自己墓地中是否存在至少1张满足条件的植物族怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c4290468.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送选择提示，提示需要从自己墓地选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地的植物族怪兽中选择1张作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c4290468.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以表侧表示从墓地除外，作为效果发动所需的COST。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 第一个效果的目标选择处理：在对方场上选择1只表侧表示怪兽作为攻击力变为一半的对象。
function c4290468.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 目标判定阶段：确认对方场上是否存在至少1只表侧表示怪兽能够成为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示，提示需要选择对方场上的1只表侧表示怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上选择1只表侧表示怪兽，并将其设置为该效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 第一个效果的处理：将对象怪兽的攻击力变为一半，持续到这个回合的结束阶段。
function c4290468.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象卡（对方场上的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- “对方场上表侧表示存在的1只怪兽的攻击力直到这个回合的结束阶段时变成一半数值。”
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		tc:RegisterEffect(e1)
	end
end
-- 第二个效果的发动条件：必须处于战斗步骤，且这张卡本回合已经进行过攻击、当前没有攻击宣言的怪兽且连锁为空时才能发动。
function c4290468.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件前半部分：当前阶段是战斗步骤，并且这张卡已经进行过攻击（攻击次数不为0）。
	return Duel.GetCurrentPhase()==PHASE_BATTLE_STEP and e:GetHandler():GetAttackedCount()~=0
		-- 条件后半部分：当前没有处于攻击宣言的怪兽（Duel.GetAttacker()==nil），且当前连锁为空（Duel.GetCurrentChain()==0），确保可以在自由时点发动。
		and Duel.GetAttacker()==nil and Duel.GetCurrentChain()==0
end
-- 第二个效果的代价处理：与第一个效果相同，将自己墓地1张植物族怪兽表侧除外作为发动代价。
function c4290468.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价判定阶段：确认自己墓地中是否存在至少1张满足条件的植物族怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c4290468.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送选择提示，提示需要从自己墓地选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地的植物族怪兽中选择1张作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c4290468.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以表侧表示从墓地除外，作为效果发动所需的COST。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 第二个效果的处理：将此卡的攻击力变为一半，并追加1次可攻击次数，效果持续到这个回合结束阶段。
function c4290468.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- “这张卡的攻击力直到结束阶段时变成一半数值”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(math.ceil(c:GetAttack()/2))
	c:RegisterEffect(e1)
	-- “只有1次再攻击”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
