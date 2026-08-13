--エレキリム
-- 效果：
-- 「电气」调整＋调整以外的雷族怪兽1只以上
-- ①：这张卡可以直接攻击。
-- ②：这张卡直接攻击给与对方战斗伤害的场合发动。从卡组选1张卡除外。发动后第2次的自己准备阶段，这个效果除外的卡加入手卡。
function c29765339.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整必须是「电气」字段怪兽，调整以外必须包含至少1只雷族怪兽。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xe),aux.NonTuner(Card.IsRace,RACE_THUNDER),1)
	c:EnableReviveLimit()
	-- ①：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ②：这张卡直接攻击给与对方战斗伤害的场合发动。从卡组选1张卡除外。发动后第2次的自己准备阶段，这个效果除外的卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29765339,0))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c29765339.condition)
	e2:SetTarget(c29765339.target)
	e2:SetOperation(c29765339.operation)
	c:RegisterEffect(e2)
end
-- 判定效果发动条件：只有当受到战斗伤害的是对方，并且该次攻击是直接攻击（没有攻击目标）时，这个诱发效果才满足发动条件。
function c29765339.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 承受战斗伤害的玩家不是己方（即为对方），且本次攻击没有攻击对象（直接攻击）。
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 效果发动时进行目标合法性检测：由于是从卡组除外，不取对象，因此只要效果可以发动就返回true，同时登记本次操作信息。
function c29765339.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果分类为除外，预计从卡组除外1张卡，目标持有者为发动者tp。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从己方卡组选择1张卡表侧表示除外，并为该卡注册一个延迟效果，使其在发动后第2次自己的准备阶段加入手卡。
function c29765339.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家提示“请选择要除外的卡”，并显示对应的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己的卡组中选1张能够被除外的卡（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,1,nil)
	local tg=g:GetFirst()
	if tg==nil then return end
	-- 将选择的卡以表侧表示除外，除外原因为效果。
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	-- 发动后第2次的自己准备阶段，这个效果除外的卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	e1:SetCondition(c29765339.thcon)
	e1:SetOperation(c29765339.thop)
	e1:SetLabel(0)
	tg:RegisterEffect(e1)
end
-- 延迟效果的发动条件：当前回合玩家是效果持有者，即到达自己的准备阶段。
function c29765339.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家等于效果持有者tp，即自己回合的准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 延迟效果处理：若标签为1，表示已经是第2次自己的准备阶段，将被除外的卡加入手卡并向对方确认；否则将标签设为1，等待下一次准备阶段。
function c29765339.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if ct==1 then
		-- 将之前除外的卡加入其持有者的手卡（nil表示返回持有者手卡），原因为效果。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		-- 向对方玩家确认那张返回手卡的卡。
		Duel.ConfirmCards(1-tp,e:GetHandler())
	else e:SetLabel(1) end
end
