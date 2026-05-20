--大革命
-- 效果：
-- 这张卡只有当处于自己的主要阶段，在自己的场上有「流离的饥民」「受弹压的民众」「团结的反抗军」表侧表示存在时才能发动。将对方的手卡全部送去墓地，将场上所有对方控制的卡全部破坏。
function c65396880.initial_effect(c)
	-- 注册该卡片记有「流离的饥民」、「受弹压的民众」和「团结的反抗军」的卡名。
	aux.AddCodeList(c,58538870,12143771,85936485)
	-- 这张卡只有当处于自己的主要阶段，在自己的场上有「流离的饥民」「受弹压的民众」「团结的反抗军」表侧表示存在时才能发动。将对方的手卡全部送去墓地，将场上所有对方控制的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c65396880.condition)
	e1:SetTarget(c65396880.target)
	e1:SetOperation(c65396880.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示存在且卡名为指定密码的卡。
function c65396880.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 发动条件：自己的主要阶段，且自己场上存在表侧表示的「流离的饥民」、「受弹压的民众」和「团结的反抗军」。
function c65396880.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段。
	local ph=Duel.GetCurrentPhase()
	-- 必须是自己的回合，且处于主要阶段1或主要阶段2。
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		-- 且自己场上存在至少1张表侧表示的「流离的饥民」。
		and Duel.IsExistingMatchingCard(c65396880.cfilter,tp,LOCATION_ONFIELD,0,1,nil,58538870)
		-- 且自己场上存在至少1张表侧表示的「受弹压的民众」。
		and Duel.IsExistingMatchingCard(c65396880.cfilter,tp,LOCATION_ONFIELD,0,1,nil,12143771)
		-- 且自己场上存在至少1张表侧表示的「团结的反抗军」。
		and Duel.IsExistingMatchingCard(c65396880.cfilter,tp,LOCATION_ONFIELD,0,1,nil,85936485)
end
-- 效果发动时的目标选择与检测：检查对方场上是否有卡或对方手牌是否不为空，并设置破坏和送去墓地的操作信息。
function c65396880.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查可行性：对方场上是否存在至少1张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
		-- 或者对方手牌数量不为0。
		or Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0 end
	-- 获取对方场上的所有卡。
	local g1=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 获取对方的所有手牌。
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 设置破坏操作信息，包含对方场上的所有卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
	-- 设置送去墓地操作信息，包含对方的所有手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g2,g2:GetCount(),0,0)
end
-- 效果处理：破坏对方场上的所有卡，并将对方的所有手牌送去墓地。
function c65396880.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡。
	local g1=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 因效果破坏获取到的对方场上的所有卡。
	Duel.Destroy(g1,REASON_EFFECT)
	-- 获取对方的所有手牌。
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 因效果将获取到的对方所有手牌送去墓地。
	Duel.SendtoGrave(g2,REASON_EFFECT)
end
