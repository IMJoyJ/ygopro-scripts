--弱肉一色
-- 效果：
-- 这张卡仅当自己场上存在5只2星以下的表侧表示的通常怪兽时才能发动。玩家各自丢弃全部手卡，并破坏场上除2星以下通常怪兽以外的所有卡。
function c66926224.initial_effect(c)
	-- 这张卡仅当自己场上存在5只2星以下的表侧表示的通常怪兽时才能发动。玩家各自丢弃全部手卡，并破坏场上除2星以下通常怪兽以外的所有卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES_SELF+CATEGORY_HANDES_OPPO)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c66926224.condition)
	e1:SetTarget(c66926224.target)
	e1:SetOperation(c66926224.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的2星以下通常怪兽
function c66926224.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevelBelow(2)
end
-- 发动条件：自己场上存在5只2星以下的表侧表示的通常怪兽
function c66926224.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在5只2星以下的表侧表示通常怪兽
	return Duel.IsExistingMatchingCard(c66926224.cfilter,tp,LOCATION_MZONE,0,5,nil)
end
-- 过滤条件：非2星以下表侧表示通常怪兽的卡
function c66926224.dfilter(c)
	return not (c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevelBelow(2))
end
-- 发动准备：检查双方手牌和场上是否存在可操作的卡，并设置对应的操作信息
function c66926224.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己手牌中除这张卡以外是否至少有1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,c)
		-- 检查对方手牌是否至少有1张卡
		and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		-- 检查场上是否存在至少1张除2星以下表侧表示通常怪兽及这张卡以外的卡
		and Duel.IsExistingMatchingCard(c66926224.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上除2星以下表侧表示通常怪兽及这张卡以外的所有卡
	local g=Duel.GetMatchingGroup(c66926224.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：双方丢弃全部手牌，并破坏场上除2星以下通常怪兽以外的所有卡
function c66926224.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方玩家的全部手牌
	local g1=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
	-- 将双方玩家的全部手牌丢弃送去墓地
	Duel.SendtoGrave(g1,REASON_EFFECT+REASON_DISCARD)
	-- 获取场上除2星以下表侧表示通常怪兽以外的所有卡
	local g2=Duel.GetMatchingGroup(c66926224.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 破坏获取到的所有卡
	Duel.Destroy(g2,REASON_EFFECT)
end
