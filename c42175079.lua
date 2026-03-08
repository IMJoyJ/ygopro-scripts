--大噴火
-- 效果：
-- 自己场上有「侏罗纪世界」存在的场合，自己的结束阶段时才能发动。场上的卡全部破坏。
function c42175079.initial_effect(c)
	-- 效果原文内容：自己场上有「侏罗纪世界」存在的场合，自己的结束阶段时才能发动。场上的卡全部破坏。
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
-- 效果作用：判断是否为结束阶段且为自己的回合且己方场上有「侏罗纪世界」
function c42175079.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断是否为结束阶段且为自己的回合
	return Duel.GetCurrentPhase()==PHASE_END and Duel.GetTurnPlayer()==tp
		-- 效果作用：判断己方场上有「侏罗纪世界」
		and Duel.IsEnvironment(10080320,tp)
end
-- 效果原文内容：自己场上有「侏罗纪世界」存在的场合，自己的结束阶段时才能发动。场上的卡全部破坏。
function c42175079.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否存在至少一张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 效果作用：获取场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 效果作用：设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果原文内容：自己场上有「侏罗纪世界」存在的场合，自己的结束阶段时才能发动。场上的卡全部破坏。
function c42175079.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取场上所有卡（排除此卡）的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 效果作用：将场上所有卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
