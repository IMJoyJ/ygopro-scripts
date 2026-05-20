--ゾーン・イーター
-- 效果：
-- 受到「区域吞噬者」攻击的怪兽，5回合后被破坏。
function c86100785.initial_effect(c)
	-- 受到「区域吞噬者」攻击的怪兽，5回合后被破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86100785,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c86100785.condition)
	e1:SetOperation(c86100785.operation)
	c:RegisterEffect(e1)
end
-- 伤害计算后，检查此卡是否为攻击怪兽，以及被攻击的怪兽是否仍表侧表示存在于场上
function c86100785.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 必须是自身进行攻击，且战斗对象存在、与本次战斗关联并表侧表示
	return c==Duel.GetAttacker() and bc and bc:IsRelateToBattle() and bc:IsFaceup()
end
-- 在受到攻击的怪兽上注册一个在回合结束时累计回合数并在5回合后将其破坏的效果
function c86100785.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 5回合后被破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetOperation(c86100785.desop)
		e1:SetLabel(0)
		e1:SetOwnerPlayer(tp)
		bc:RegisterEffect(e1)
	end
end
-- 在每个回合结束时使回合计数器加1，当计数器累计到5时，将该怪兽破坏
function c86100785.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct+1
	e:SetLabel(ct)
	e:GetOwner():SetTurnCounter(ct)
	if ct==5 then
		-- 因效果将该怪兽（效果注册的宿主怪兽）破坏
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
