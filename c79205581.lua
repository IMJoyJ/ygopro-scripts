--強制終了
-- 效果：
-- 可以把自己场上存在的这张卡以外的1张卡送去墓地，这个回合的战斗阶段结束。这个效果在战斗阶段时才能发动。
function c79205581.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 可以把自己场上存在的这张卡以外的1张卡送去墓地，这个回合的战斗阶段结束。这个效果在战斗阶段时才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79205581,0))  --"战斗阶段结束"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c79205581.condition)
	e2:SetTarget(c79205581.cost)
	e2:SetOperation(c79205581.operation)
	c:RegisterEffect(e2)
end
-- 定义效果发动的条件函数，限制在战斗阶段才能发动
function c79205581.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否处于战斗阶段（从战斗阶段开始到战斗阶段结束前）
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<PHASE_BATTLE
end
-- 定义效果发动的代价函数，将自身以外的场上1张卡送去墓地
function c79205581.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动阶段检查自己场上是否存在除这张卡以外、可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,c) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上除这张卡以外的1张可以作为代价送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义效果处理函数，使这个回合的战斗阶段结束
function c79205581.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过当前回合玩家的战斗阶段，使其直接进入战斗阶段的结束步骤（即结束战斗阶段）
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
