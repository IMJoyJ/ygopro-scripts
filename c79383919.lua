--断罪の呪眼
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「咒眼」怪兽存在，魔法·陷阱卡发动时才能发动。那个发动无效并破坏。自己的魔法与陷阱区域有「太阴之咒眼」存在的场合，这张卡的发动和效果不会被无效化。
function c79383919.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「咒眼」怪兽存在，魔法·陷阱卡发动时才能发动。那个发动无效并破坏。自己的魔法与陷阱区域有「太阴之咒眼」存在的场合，这张卡的发动和效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,79383919+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c79383919.condition)
	e1:SetTarget(c79383919.target)
	e1:SetOperation(c79383919.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「咒眼」怪兽
function c79383919.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x129)
end
-- 发动条件：魔法·陷阱卡发动时，且自己场上有「咒眼」怪兽存在
function c79383919.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动的效果是否为魔法·陷阱卡的发动，且该发动可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在表侧表示的「咒眼」怪兽
		and Duel.IsExistingMatchingCard(c79383919.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：自己魔法与陷阱区域表侧表示的「太阴之咒眼」
function c79383919.filter(c)
	return c:IsFaceup() and c:IsCode(44133040)
end
-- 效果的目标处理：若满足特定条件则使这张卡的发动和效果不会被无效化，并设置无效与破坏的操作信息
function c79383919.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 检查自己的魔法与陷阱区域是否存在表侧表示的「太阴之咒眼」
		and Duel.IsExistingMatchingCard(c79383919.filter,tp,LOCATION_SZONE,0,1,nil) then
		e:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	else
		e:SetProperty(0)
	end
	-- 设置操作信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果的处理：使发动的魔法·陷阱卡的发动无效并破坏
function c79383919.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且该卡在连锁中关系确立
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
