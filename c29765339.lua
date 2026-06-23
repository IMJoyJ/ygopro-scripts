--エレキリム
-- 效果：
-- 「电气」调整＋调整以外的雷族怪兽1只以上
-- ①：这张卡可以直接攻击。
-- ②：这张卡直接攻击给与对方战斗伤害的场合发动。从卡组选1张卡除外。发动后第2次的自己准备阶段，这个效果除外的卡加入手卡。
function c29765339.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整（电气族）+1只以上调整以外的雷族怪兽
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
-- 判断是否为直接攻击造成的战斗伤害且攻击对象为空
function c29765339.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 满足非攻击玩家且无攻击对象的条件
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 设置连锁操作信息，指定除外1张卡
function c29765339.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为除外卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动，选择并除外卡组中的1张卡
function c29765339.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组中选择1张可除外的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,1,nil)
	local tg=g:GetFirst()
	if tg==nil then return end
	-- 将选中的卡除外
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	-- 为除外的卡添加准备阶段效果，用于在第2次准备阶段时将其加入手卡
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
-- 判断是否为当前玩家的准备阶段
function c29765339.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段效果的处理函数，控制卡加入手卡或标记为已处理
function c29765339.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if ct==1 then
		-- 将除外的卡加入手卡
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,e:GetHandler())
	else e:SetLabel(1) end
end
