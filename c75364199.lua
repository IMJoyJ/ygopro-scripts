--相視相殺
-- 效果：
-- ①：这个回合，双方玩家把手卡持续公开。这个效果把手卡持续公开期间，双方手卡有同名卡存在的场合，双方不能作那卡以及那些同名卡的效果的发动。
function c75364199.initial_effect(c)
	-- ①：这个回合，双方玩家把手卡持续公开。这个效果把手卡持续公开期间，双方手卡有同名卡存在的场合，双方不能作那卡以及那些同名卡的效果的发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetOperation(c75364199.activate)
	c:RegisterEffect(e1)
end
-- 卡片发动时的效果处理：在当前回合内，注册双方手牌公开以及限制同名卡效果发动的两个全局效果
function c75364199.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，双方玩家把手卡持续公开。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向全局环境注册双方手牌持续公开的效果
	Duel.RegisterEffect(e1,tp)
	-- 这个效果把手卡持续公开期间，双方手卡有同名卡存在的场合，双方不能作那卡以及那些同名卡的效果的发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(c75364199.acttg)
	-- 向全局环境注册限制双方玩家发动特定卡片效果的效果
	Duel.RegisterEffect(e2,tp)
end
-- 判断准备发动的效果是否属于双方公开的手牌中都存在的同名卡，若是则限制其发动
function c75364199.acttg(e,re,tp)
	local tc=re:GetHandler()
	-- 获取自己手牌中处于公开状态的卡片组
	local g1=Duel.GetMatchingGroup(Card.IsPublic,tp,LOCATION_HAND,0,nil)
	-- 获取对方手牌中处于公开状态的卡片组
	local g2=Duel.GetMatchingGroup(Card.IsPublic,tp,0,LOCATION_HAND,nil)
	return g1:IsExists(Card.IsCode,1,nil,tc:GetCode()) and g2:IsExists(Card.IsCode,1,nil,tc:GetCode())
end
