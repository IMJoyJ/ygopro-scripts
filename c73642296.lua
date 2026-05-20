--屋敷わらし
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：包含以下其中任意种效果的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个发动无效。
-- ●从墓地把卡加入手卡·卡组·额外卡组的效果
-- ●从墓地把怪兽特殊召唤的效果
-- ●从墓地把卡除外的效果
function c73642296.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：包含以下其中任意种效果的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个发动无效。●从墓地把卡加入手卡·卡组·额外卡组的效果●从墓地把怪兽特殊召唤的效果●从墓地把卡除外的效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73642296,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,73642296)
	e1:SetCondition(c73642296.discon)
	e1:SetCost(c73642296.discost)
	e1:SetTarget(c73642296.distg)
	e1:SetOperation(c73642296.disop)
	c:RegisterEffect(e1)
end
-- 过滤条件：判断目标卡片是否在墓地且是怪兽卡
function c73642296.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)
end
-- 判断发动条件：检查被连锁的效果是否包含从墓地回收卡、特殊召唤怪兽、除外卡片等操作，且该发动可以被无效
function c73642296.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被连锁效果中将卡加入手牌的操作信息
	local ex1,g1,gc1,dp1,dv1=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	-- 获取被连锁效果中将卡加入卡组的操作信息
	local ex2,g2,gc2,dp2,dv2=Duel.GetOperationInfo(ev,CATEGORY_TODECK)
	-- 获取被连锁效果中将卡加入额外卡组的操作信息
	local ex3,g3,gc3,dp3,dv3=Duel.GetOperationInfo(ev,CATEGORY_TOEXTRA)
	-- 获取被连锁效果中特殊召唤怪兽的操作信息
	local ex4,g4,gc4,dp4,dv4=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	-- 获取被连锁效果中除外卡片的操作信息
	local ex5,g5,gc5,dp5,dv5=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	return ((ex1 and (dv1&LOCATION_GRAVE==LOCATION_GRAVE or g1 and g1:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)))
		or (ex2 and (dv2&LOCATION_GRAVE==LOCATION_GRAVE or g2 and g2:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)))
		or (ex3 and (dv3&LOCATION_GRAVE==LOCATION_GRAVE or g3 and g3:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)))
		or (ex4 and (dv4&LOCATION_GRAVE==LOCATION_GRAVE or g4 and g4:IsExists(c73642296.cfilter,1,nil)))
		or (ex5 and (dv5&LOCATION_GRAVE==LOCATION_GRAVE or g5 and g5:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)))
		or re:IsHasCategory(CATEGORY_GRAVE_SPSUMMON)
		or re:IsHasCategory(CATEGORY_GRAVE_ACTION))
		-- 并且该连锁的发动是可以被无效的
		and Duel.IsChainNegatable(ev)
end
-- 效果发动的代价：检查并把这张卡从手卡丢弃
function c73642296.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动代价，将这张卡丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 效果发动的目标：设置使发动无效的操作信息
function c73642296.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果处理：使该连锁的发动无效
function c73642296.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效
	Duel.NegateActivation(ev)
end
