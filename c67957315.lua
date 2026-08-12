--スピリット・ドラゴン
-- 效果：
-- 这张卡进行战斗的自己的战斗步骤时，从手卡把1只龙族怪兽丢弃去墓地才能发动。这张卡的攻击力·守备力直到战斗阶段结束时上升1000。
function c67957315.initial_effect(c)
	-- 这张卡进行战斗的自己的战斗步骤时，从手卡把1只龙族怪兽丢弃去墓地才能发动。这张卡的攻击力·守备力直到战斗阶段结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67957315,0))  --"攻守上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_BATTLE_PHASE+TIMING_CHAIN_END)
	e1:SetCondition(c67957315.adcon)
	e1:SetCost(c67957315.adcost)
	e1:SetOperation(c67957315.adop)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件：自己的战斗阶段且此卡正在进行战斗
function c67957315.adcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合且处于战斗阶段
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
		-- 检查此卡是否为攻击怪兽或被攻击对象（即正在进行战斗）
		and (e:GetHandler()==Duel.GetAttacker() or e:GetHandler()==Duel.GetAttackTarget())
end
-- 过滤手牌中可丢弃的龙族怪兽
function c67957315.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 发动代价：从手牌将1只龙族怪兽丢弃去墓地
function c67957315.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认手牌中是否存在至少1只龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67957315.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中选择1只龙族怪兽作为代价丢弃去墓地
	Duel.DiscardHand(tp,c67957315.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果处理：使此卡的攻击力和守备力直到战斗阶段结束时上升1000
function c67957315.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力……直到战斗阶段结束时上升1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
