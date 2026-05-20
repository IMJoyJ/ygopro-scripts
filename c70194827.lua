--ブレード・バウンサー
-- 效果：
-- 这张卡进行攻击的伤害步骤结束时，对方场上有怪兽存在的场合，丢弃1张手卡才能发动。这次战斗阶段中，这张卡只有1次可以向对方怪兽再攻击。这个效果1回合只能使用1次。
function c70194827.initial_effect(c)
	-- 这张卡进行攻击的伤害步骤结束时，对方场上有怪兽存在的场合，丢弃1张手卡才能发动。这次战斗阶段中，这张卡只有1次可以向对方怪兽再攻击。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70194827,0))  --"再次攻击"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c70194827.atcon)
	e1:SetCost(c70194827.atcost)
	e1:SetOperation(c70194827.atop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：此卡进行攻击的伤害步骤结束时，且对方场上有怪兽存在
function c70194827.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否是本次战斗的攻击怪兽，且在伤害步骤结束时仍与战斗相关联（未离场）
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
		-- 检查对方场上是否存在怪兽
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0
end
-- 检查并执行发动代价：丢弃1张手卡
function c70194827.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 执行效果处理：给此卡添加不能直接攻击以及可以再攻击1次的持续效果
function c70194827.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() then return end
	-- 向对方怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
	-- 这次战斗阶段中，这张卡只有1次可以……再攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e2)
end
