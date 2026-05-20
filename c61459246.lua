--夢魔鏡の夢占い
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以把以下效果发动。
-- ●场地区域有「圣光之梦魔镜」存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ●场地区域有「黯黑之梦魔镜」存在，对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
function c61459246.initial_effect(c)
	-- 将「圣光之梦魔镜」和「黯黑之梦魔镜」的卡片密码注册到本卡的关联卡片列表中。
	aux.AddCodeList(c,74665651,1050355)
	-- 这个卡名的卡在1回合只能发动1张。①：可以把以下效果发动。●场地区域有「圣光之梦魔镜」存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,61459246+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c61459246.condition1)
	e1:SetTarget(c61459246.target1)
	e1:SetOperation(c61459246.activate1)
	c:RegisterEffect(e1)
	-- 这个卡名的卡在1回合只能发动1张。①：可以把以下效果发动。●场地区域有「黯黑之梦魔镜」存在，对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetCountLimit(1,61459246+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(c61459246.condition2)
	e2:SetTarget(c61459246.target2)
	e2:SetOperation(c61459246.activate2)
	c:RegisterEffect(e2)
end
-- 定义效果①（无效魔法·陷阱卡发动并破坏）的发动条件判定函数。
function c61459246.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查被连锁的效果是否为对方发动的魔法·陷阱卡的发动，且该发动可被无效，同时场地区域存在「圣光之梦魔镜」。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev) and rp==1-tp and Duel.IsEnvironment(74665651,PLAYER_ALL,LOCATION_FZONE)
end
-- 定义效果①（无效魔法·陷阱卡发动并破坏）的靶向与操作信息设置函数。
function c61459246.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果包含使发动无效的操作。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动的卡可被破坏且与效果有关联，则设置操作信息，表示该效果包含破坏该卡的操作。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义效果①（无效魔法·陷阱卡发动并破坏）的效果处理函数。
function c61459246.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使该连锁的发动无效，且该卡与效果有关联，则执行后续处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该发动被无效的卡片因效果破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 定义效果②（无效特殊召唤并破坏）的发动条件判定函数。
function c61459246.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否处于非连锁状态下的特殊召唤之际、是否为对方进行的特殊召唤，且场地区域存在「黯黑之梦魔镜」。
	return aux.NegateSummonCondition() and rp==1-tp and Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE)
end
-- 定义效果②（无效特殊召唤并破坏）的靶向与操作信息设置函数。
function c61459246.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果包含无效特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息，表示该效果包含破坏那些特殊召唤怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 定义效果②（无效特殊召唤并破坏）的效果处理函数。
function c61459246.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在特殊召唤的怪兽的特殊召唤无效。
	Duel.NegateSummon(eg)
	-- 将那些特殊召唤被无效的怪兽因效果破坏。
	Duel.Destroy(eg,REASON_EFFECT)
end
