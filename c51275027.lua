--薄幸の美少女
-- 效果：
-- 这张卡被战斗破坏送去墓地，当时那个回合的战斗阶段结束。
function c51275027.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地，当时那个回合的战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51275027,0))  --"结束战斗阶段"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c51275027.condition)
	e1:SetOperation(c51275027.operation)
	c:RegisterEffect(e1)
end
-- 检查触发效果的卡是否在墓地且因战斗破坏而离场
function c51275027.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 跳过当前回合玩家的战斗阶段
function c51275027.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过指定玩家的战斗阶段并重置相关步骤
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
