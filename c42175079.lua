--大噴火
-- 效果：
-- 自己场上有「侏罗纪世界」存在的场合，自己的结束阶段时才能发动。场上的卡全部破坏。
function c42175079.initial_effect(c)
	-- 自己场上有「侏罗纪世界」存在的场合，自己的结束阶段时才能发动。场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE,0)
	e1:SetCondition(c42175079.condition)
	e1:SetTarget(c42175079.target)
	e1:SetOperation(c42175079.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定函数：判断是否满足“自己场上有「侏罗纪世界」存在且为自己的结束阶段”的发动条件。
function c42175079.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为自己回合的结束阶段。
	return Duel.GetCurrentPhase()==PHASE_END and Duel.GetTurnPlayer()==tp
		-- 检查自己场上是否存在「侏罗纪世界」（通过场地魔法环境判断，卡号10080320）。
		and Duel.IsEnvironment(10080320,tp)
end
-- 效果发动时的目标处理函数：进行发动合法性检查并登记场上全部卡片将被破坏的操作信息。
function c42175079.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：确认场上除本卡外是否存在任意卡片，以保证破坏效果有对象可处理。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上除本卡外的所有卡片，作为效果处理时可能破坏的对象集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 登记操作信息：将获取到的卡片组及数量写入连锁信息，类别为破坏，用于后续时点与连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数：效果处理时重新检索场上除本卡外的所有卡并全部破坏。
function c42175079.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除本卡外的所有卡片（不取对象，处理时选择）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 以效果为原因，将这些卡片全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
