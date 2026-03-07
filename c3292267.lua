--聖刻天龍－エネアード
-- 效果：
-- 8星怪兽×2
-- ①：1回合1次，以自己的场上·墓地的卡或者除外的自己的卡为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c3292267.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加等级为8、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,8,2)
	-- ①：1回合1次，以自己的场上·墓地的卡或者除外的自己的卡为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3292267,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c3292267.discon)
	e1:SetCost(c3292267.discost)
	e1:SetTarget(c3292267.distg)
	e1:SetOperation(c3292267.disop)
	c:RegisterEffect(e1)
end
-- 定义目标卡片过滤器，用于判断卡片是否在场上、墓地或除外区且属于当前玩家控制
function c3292267.tfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED) and c:IsControler(tp)
end
-- 效果发动条件函数，判断是否满足发动条件：对方发动效果、效果有对象、对象卡片存在且属于己方、连锁可无效
function c3292267.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断对象卡片组中是否存在满足过滤条件的卡片且连锁可无效
	return tg and tg:IsExists(c3292267.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 效果发动的费用支付函数，消耗1个超量素材作为代价
function c3292267.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动时的目标设定函数，设置连锁无效和破坏的处理信息
function c3292267.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁无效的处理信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁破坏的处理信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果发动时的处理函数，使连锁无效并破坏对象卡片
function c3292267.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否成功无效且对象卡片有效存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对象卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
