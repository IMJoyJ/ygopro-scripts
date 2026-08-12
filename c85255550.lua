--異国の剣士
-- 效果：
-- 受到「异国的剑士」攻击的怪兽，5回合后被破坏。
function c85255550.initial_effect(c)
	-- 受到「异国的剑士」攻击的怪兽，5回合后被破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85255550,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c85255550.condition)
	e1:SetOperation(c85255550.operation)
	c:RegisterEffect(e1)
end
-- 判断发动条件：此卡进行攻击，且被攻击的怪兽在伤害计算后仍表侧表示存在。
function c85255550.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 确认此卡是攻击怪兽，且被攻击的怪兽与战斗相关并表侧表示存在。
	return c==Duel.GetAttacker() and bc and bc:IsRelateToBattle() and bc:IsFaceup()
end
-- 效果处理：给被攻击的怪兽注册一个在回合结束时累计回合数并在5回合后将其破坏的效果。
function c85255550.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 5回合后被破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetOperation(c85255550.desop)
		e1:SetLabel(0)
		e1:SetOwnerPlayer(tp)
		bc:RegisterEffect(e1)
	end
end
-- 在每个回合结束阶段使回合计数器加1，当计数达到5时将该怪兽破坏。
function c85255550.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct+1
	e:SetLabel(ct)
	e:GetOwner():SetTurnCounter(ct)
	if ct==5 then
		-- 因效果将该怪兽破坏。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
