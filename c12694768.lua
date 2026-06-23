--暴鬼
-- 效果：
-- 这张卡被战斗破坏送去墓地时，双方受到500分伤害。
function c12694768.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，双方受到500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12694768,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c12694768.condition)
	e1:SetTarget(c12694768.target)
	e1:SetOperation(c12694768.operation)
	c:RegisterEffect(e1)
end
-- 判断触发条件：卡片在墓地且因战斗破坏被送入墓地
function c12694768.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 设置效果目标：为双方各造成500点伤害
function c12694768.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：指定将对双方各造成500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,500)
end
-- 效果处理函数：执行双方各受500点伤害的效果
function c12694768.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 对当前玩家造成500点伤害
	Duel.Damage(tp,500,REASON_EFFECT,true)
	-- 对对方玩家造成500点伤害
	Duel.Damage(1-tp,500,REASON_EFFECT,true)
	-- 完成伤害处理时点
	Duel.RDComplete()
end
