--超電磁タートル
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。
-- ①：对方战斗阶段把墓地的这张卡除外才能发动。那次战斗阶段结束。
function c34710660.initial_effect(c)
	-- 这个卡名的效果在决斗中只能使用1次。①：对方战斗阶段把墓地的这张卡除外才能发动。那次战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34710660,0))  --"战斗阶段结束"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,34710660+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c34710660.condition)
	-- 设置效果发动代价：将墓地中的这张卡自身除外（作为发动COST）。
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c34710660.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：仅在对方回合且处于战斗阶段（当前阶段在 PHASE_BATTLE_START 与 PHASE_BATTLE 之间）时才可发动。
function c34710660.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真当且仅当当前是对方回合且当前阶段处于战斗阶段范围内。
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 定义效果处理：跳过对方玩家的战斗阶段，使那次战斗阶段直接结束。
function c34710660.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 调用 Duel.SkipPhase 将对方玩家（1-tp）的战斗阶段跳过，并以战斗步骤后的阶段结束作为重置时机；value=1 表示跳过战斗阶段的结束步骤，实现战斗阶段强制结束。
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
