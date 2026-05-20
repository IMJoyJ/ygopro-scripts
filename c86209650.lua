--迷走悪魔
-- 效果：
-- 这张卡被战斗破坏送去墓地时，双方回复800基本分。
function c86209650.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，双方回复800基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86209650,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c86209650.condition)
	e1:SetTarget(c86209650.target)
	e1:SetOperation(c86209650.operation)
	c:RegisterEffect(e1)
end
-- 检查此卡是否在墓地且是被战斗破坏送去墓地的
function c86209650.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果发动的目标，确认是否可以发动并设置回复基本分的操作信息
function c86209650.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为双方玩家回复800基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,800)
end
-- 效果处理的执行，使双方玩家各回复800基本分
function c86209650.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己回复800基本分
	Duel.Recover(tp,800,REASON_EFFECT)
	-- 使对方回复800基本分
	Duel.Recover(1-tp,800,REASON_EFFECT)
end
