--絶対なる捕食
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：通常召唤的怪兽在自己场上存在的场合才能发动。场上的特殊召唤的怪兽全部破坏。这张卡的发动后，直到下次的自己回合的结束时自己不能通常召唤。
function c25573115.initial_effect(c)
	-- 创建并注册卡牌效果，设置为发动时点、破坏类别、限制发动次数为1次、条件为己方场上存在通常召唤的怪兽、目标为己方场上特殊召唤的怪兽、发动时点提示为怪兽召唤和结束阶段
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
-- 效果条件：己方场上存在通常召唤的怪兽
function c25573115.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少1只通常召唤的怪兽
	return Duel.IsExistingMatchingCard(Card.IsSummonType,tp,LOCATION_MZONE,0,1,nil,SUMMON_TYPE_NORMAL)
end
-- 效果目标：检索己方场上所有特殊召唤的怪兽并设置为破坏对象
function c25573115.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方场上所有特殊召唤的怪兽作为目标组
	local g=Duel.GetMatchingGroup(Card.IsSummonType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	if chk==0 then return #g>0 end
	-- 设置连锁操作信息为破坏效果，目标为特殊召唤怪兽组，数量为组中怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果发动：若为发动状态则设置不能通常召唤和不能覆盖的限制效果，然后破坏场上所有特殊召唤的怪兽
function c25573115.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 判断当前回合玩家是否为效果使用者，若为是则限制2个回合，否则限制1个回合
		local ct=(Duel.GetTurnPlayer()==tp) and 2 or 1
		-- 设置不能通常召唤和不能覆盖怪兽的效果，持续到指定回合结束
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,ct)
		e1:SetTargetRange(1,0)
		-- 将不能通常召唤的效果注册给当前玩家
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_MSET)
		-- 将不能覆盖怪兽的效果注册给当前玩家
		Duel.RegisterEffect(e2,tp)
	end
	-- 再次获取己方场上所有特殊召唤的怪兽作为目标组
	local g=Duel.GetMatchingGroup(Card.IsSummonType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	if #g>0 then
		-- 以效果原因破坏目标怪兽组
		Duel.Destroy(g,REASON_EFFECT)
	end
end
