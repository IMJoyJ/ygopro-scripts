--皇の波動
-- 效果：
-- 把自己场上存在的1个超量素材取除发动。自己场上表侧表示存在的超量怪兽直到结束阶段时不会被卡的效果破坏。
function c59070329.initial_effect(c)
	-- 把自己场上存在的1个超量素材取除发动。自己场上表侧表示存在的超量怪兽直到结束阶段时不会被卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c59070329.cost)
	e1:SetTarget(c59070329.target)
	e1:SetOperation(c59070329.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价，用于检查并取除超量素材
function c59070329.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否存在至少1个可以作为代价取除的超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 从自己场上取除1个超量素材作为发动代价
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 定义效果的目标，用于在发动时确认是否存在合法的受影响对象
function c59070329.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c59070329.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 过滤条件：表侧表示且是超量怪兽
function c59070329.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 定义效果处理，遍历并给符合条件的怪兽添加效果破坏抗性
function c59070329.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上当前所有表侧表示的超量怪兽
	local g=Duel.GetMatchingGroup(c59070329.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 直到结束阶段时不会被卡的效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
