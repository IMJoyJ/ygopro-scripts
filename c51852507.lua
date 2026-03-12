--薔薇の聖弓手
-- 效果：
-- 自己场上有植物族怪兽存在，对方把陷阱卡发动时，把这张卡从手卡送去墓地才能发动。那个发动无效并破坏。这个效果在对方回合也能发动。
function c51852507.initial_effect(c)
	-- 创建效果，描述为“陷阱无效并破坏”，设置Category为无效和破坏，类型为诱发即时效果，触发事件是连锁发动，属性为伤害步骤和伤害计算时可发动，发动位置为手卡，条件函数为discon，费用函数为discost，目标函数为distg，效果处理函数为disop
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51852507,0))  --"陷阱无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c51852507.discon)
	e1:SetCost(c51852507.discost)
	e1:SetTarget(c51852507.distg)
	e1:SetOperation(c51852507.disop)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查场上是否有表侧表示的植物族怪兽
function c51852507.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 效果发动条件函数，判断是否为对方发动陷阱卡且该连锁可被无效，并且自己场上有植物族怪兽
function c51852507.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动陷阱卡且该连锁可被无效
	return ep~=tp and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 自己场上有植物族怪兽存在
		and Duel.IsExistingMatchingCard(c51852507.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 费用函数，检查手牌是否能送入墓地作为费用，若可以则执行送入墓地操作
function c51852507.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身从手卡送入墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 目标设定函数，设置连锁无效和可能的破坏对象
function c51852507.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏发动时可能影响的对象的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数，使连锁无效并破坏对应卡片
function c51852507.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否成功无效且对应卡片是否存在并关联到该效果
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对应卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
