--聖刻天龍－エネアード
-- 效果：
-- 8星怪兽×2
-- ①：1回合1次，以自己的场上·墓地的卡或者除外的自己的卡为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c3292267.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加超量召唤手续：使用2只8星怪兽叠放来超量召唤。
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
-- 筛选条件：卡位于场上·墓地·除外区且控制者为发动者tp，即属于“自己的场上·墓地的卡或者除外的自己的卡”。
function c3292267.tfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED) and c:IsControler(tp)
end
-- 发动条件：对方发动以自己场上·墓地·除外区的卡为对象的魔法·陷阱·怪兽效果，且此卡未被战斗破坏确定，且该连锁能够被无效。
function c3292267.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取该连锁效果所取的对象卡组，用于检查对象中是否存在符合条件的自己的卡。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断对象卡组中存在至少1张符合tfilter的自己的卡，并且该效果的发动可以被无效。
	return tg and tg:IsExists(c3292267.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 发动代价：从这张卡上取除1个超量素材来作为发动费用的cost。
function c3292267.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动时的目标处理：声明可以发动，并设置“无效发动”与“破坏”相关的操作信息。
function c3292267.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果处理包含使对方效果发动无效的分类CATEGORY_NEGATE。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：若对方效果的那张卡可被破坏且仍与效果相关，则本次处理包含将其破坏的分类CATEGORY_DESTROY。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先无效对方效果的发动，若该卡仍与效果相关则将其破坏。
function c3292267.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否成功无效了对方效果的发动，且发动效果的那张卡仍与效果存在联系，避免处理已经离场或无关的对象。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动的效果的那张卡以效果破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
