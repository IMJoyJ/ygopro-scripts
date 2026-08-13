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
-- 效果发动条件：这张卡被战斗破坏后位于墓地，且破坏原因为战斗破坏。
function c12694768.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果发动时的处理：该效果无需选择对象，直接返回true并在效果处理前登记伤害操作信息。
function c12694768.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记伤害操作信息：向双方玩家各造成500点伤害，伤害分类为效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,500)
end
-- 效果处理时的操作：双方各受到500点效果伤害，并在伤害处理后触发相关时点。
function c12694768.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡的控制者受到500点效果伤害。
	Duel.Damage(tp,500,REASON_EFFECT,true)
	-- 这张卡的控制者的对方玩家受到500点效果伤害。
	Duel.Damage(1-tp,500,REASON_EFFECT,true)
	-- 完成伤害处理步骤，触发“受到伤害”等相关时点。
	Duel.RDComplete()
end
