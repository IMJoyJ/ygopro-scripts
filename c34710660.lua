--超電磁タートル
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。
-- ①：对方战斗阶段把墓地的这张卡除外才能发动。那次战斗阶段结束。
function c34710660.initial_effect(c)
	-- ①：对方战斗阶段把墓地的这张卡除外才能发动。那次战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34710660,0))  --"战斗阶段结束"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,34710660+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c34710660.condition)
	-- 将这张卡除外作为cost
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c34710660.operation)
	c:RegisterEffect(e1)
end
-- 检查是否为对方的战斗阶段
function c34710660.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方回合且当前阶段为战斗阶段开始到战斗阶段结束之间
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 跳过对方的战斗阶段
function c34710660.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过对方的战斗阶段结束步骤
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
