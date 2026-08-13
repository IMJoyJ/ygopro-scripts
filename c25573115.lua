--絶対なる捕食
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：通常召唤的怪兽在自己场上存在的场合才能发动。场上的特殊召唤的怪兽全部破坏。这张卡的发动后，直到下次的自己回合的结束时自己不能通常召唤。
function c25573115.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：通常召唤的怪兽在自己场上存在的场合才能发动。场上的特殊召唤的怪兽全部破坏。这张卡的发动后，直到下次的自己回合的结束时自己不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25573115,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,25573115+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c25573115.condition)
	e1:SetTarget(c25573115.target)
	e1:SetOperation(c25573115.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：自己场上有通过通常召唤出场的怪兽存在时才能发动（检查是否存在召唤类型为通常召唤的怪兽）。
function c25573115.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只召唤类型为通常召唤的怪兽。
	return Duel.IsExistingMatchingCard(Card.IsSummonType,tp,LOCATION_MZONE,0,1,nil,SUMMON_TYPE_NORMAL)
end
-- 发动时选择目标：获取双方场上所有特殊召唤的怪兽，确认存在后，设置将破坏这些怪兽的效果信息。
function c25573115.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上所有特殊召唤的怪兽（攻击表示/守备表示均可）。
	local g=Duel.GetMatchingGroup(Card.IsSummonType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	if chk==0 then return #g>0 end
	-- 设置操作信息：本次处理将破坏上述g中的所有怪兽，数量为g的数量，用于连锁处理时的效果判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果处理：先给发动者附加“不能通常召唤/不能覆盖怪兽”的自肃效果，再破坏双方场上所有特殊召唤的怪兽。
function c25573115.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 计算自肃效果持续的阶段数：若当前回合是发动者自己的回合，则持续到下次自己回合结束（经过2个结束阶段）；否则持续到下次自己回合结束（经过1个结束阶段）。
		local ct=(Duel.GetTurnPlayer()==tp) and 2 or 1
		-- 场上的特殊召唤的怪兽全部破坏。这张卡的发动后，直到下次的自己回合的结束时自己不能通常召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,ct)
		e1:SetTargetRange(1,0)
		-- 向发动者tp注册一个永续效果：发动者不能进行通常召唤（覆盖怪兽也受此限制）。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_MSET)
		-- 向发动者tp注册一个永续效果：发动者不能覆盖怪兽（通常召唤/覆盖均禁止）。
		Duel.RegisterEffect(e2,tp)
	end
	-- 处理破坏时重新获取双方场上所有特殊召唤的怪兽（确保当前仍在场上的对象）。
	local g=Duel.GetMatchingGroup(Card.IsSummonType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	if #g>0 then
		-- 以效果破坏上述所有特殊召唤的怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
