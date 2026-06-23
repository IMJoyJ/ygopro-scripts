--灰流うらら
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：包含以下其中任意种效果的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个效果无效。
-- ●从卡组把卡加入手卡的效果
-- ●从卡组把怪兽特殊召唤的效果
-- ●从卡组把卡送去墓地的效果
function c14558127.initial_effect(c)
	-- 创建效果，设置为二速诱发即时效果，连锁发动时触发，只能在手卡发动，一回合只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,14558127)
	e1:SetCondition(c14558127.discon)
	e1:SetCost(c14558127.discost)
	e1:SetTarget(c14558127.distg)
	e1:SetOperation(c14558127.disop)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断函数
function c14558127.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果中是否包含从卡组特殊召唤的效果
	local ex2,g2,gc2,dp2,dv2=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	-- 获取连锁效果中是否包含从卡组送去墓地的效果
	local ex3,g3,gc3,dp3,dv3=Duel.GetOperationInfo(ev,CATEGORY_TOGRAVE)
	local ex4=re:IsHasCategory(CATEGORY_DRAW)
	local ex5=re:IsHasCategory(CATEGORY_SEARCH)
	local ex6=re:IsHasCategory(CATEGORY_DECKDES)
	return ((ex2 and bit.band(dv2,LOCATION_DECK)==LOCATION_DECK)
		or (ex3 and bit.band(dv3,LOCATION_DECK)==LOCATION_DECK)
		-- 判断连锁效果是否可以被无效，且满足上述条件之一
		or ex4 or ex5 or ex6) and Duel.IsChainDisablable(ev)
end
-- 丢弃费用的处理函数
function c14558127.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将自身从手卡丢弃作为发动代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 设置连锁效果无效的处理函数
function c14558127.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁操作信息为使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 使连锁效果无效的实际操作函数
function c14558127.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的效果无效
	Duel.NegateEffect(ev)
end
