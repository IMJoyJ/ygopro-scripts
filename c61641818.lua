--電脳堺龍－龍々
-- 效果：
-- 相同种族·属性的3星怪兽×2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：持有超量素材的这张卡不会成为对方的效果的对象。
-- ②：对方场上有表侧表示怪兽存在，对方把不在自身场上存在的属性的怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个发动无效。
function c61641818.initial_effect(c)
	-- 为这张卡添加无等级限制的XYZ召唤手续，指定素材过滤和检查函数，并设置素材数量范围为2到99只
	aux.AddXyzProcedureLevelFree(c,c61641818.mfilter,c61641818.xyzcheck,2,99)
	c:EnableReviveLimit()
	-- ①：持有超量素材的这张卡不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置不能成为效果对象的目标为对方玩家的效果
	e1:SetValue(aux.tgoval)
	e1:SetCondition(c61641818.etcon)
	c:RegisterEffect(e1)
	-- ②：对方场上有表侧表示怪兽存在，对方把不在自身场上存在的属性的怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61641818,0))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,61641818)
	e2:SetCondition(c61641818.discon)
	e2:SetCost(c61641818.discost)
	e2:SetTarget(c61641818.distg)
	e2:SetOperation(c61641818.disop)
	c:RegisterEffect(e2)
end
-- XYZ素材过滤函数：必须是3星怪兽
function c61641818.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsXyzLevel(xyzc,3)
end
-- XYZ素材组检查函数：检查整组素材是否满足特定条件
function c61641818.xyzcheck(g)
	-- 检查素材组中所有怪兽的种族是否全部相同，且属性是否全部相同
	return aux.SameValueCheck(g,Card.GetRace) and aux.SameValueCheck(g,Card.GetAttribute)
end
-- 效果1的启用条件：这张卡的超量素材数量不为0（持有超量素材）
function c61641818.etcon(e)
	return e:GetHandler():GetOverlayCount()~=0
end
-- 效果2的发动条件检查：对方场上有表侧表示怪兽存在，且对方发动的怪兽效果的属性不在对方场上表侧表示怪兽的属性之中
function c61641818.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 过滤非对方发动的效果、自身已被战斗破坏的情况，以及无法被无效的发动
	if ep==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	-- 获取对方场上所有表侧表示的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 or not re:IsActiveType(TYPE_MONSTER) then return false end
	local tc=g:GetFirst()
	local attr=0
	while tc do
		attr=attr|tc:GetAttribute()
		tc=g:GetNext()
	end
	-- 获取当前连锁中发动效果的怪兽的属性
	local rattr=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_ATTRIBUTE)
	return rattr&attr==0
end
-- 效果2的发动代价：取除这张卡的2个超量素材
function c61641818.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	-- 给玩家发送提示信息，要求选择要取除的超量素材
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果2的目标检查与操作信息设置
function c61641818.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为“使发动无效”，目标为当前连锁发动的卡
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果2的效果处理：使该发动无效
function c61641818.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前连锁的发动
	Duel.NegateActivation(ev)
end
