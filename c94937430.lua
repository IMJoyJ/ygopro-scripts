--臨時収入
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，每次自己的额外卡组有卡加入，给这张卡放置1个魔力指示物（最多3个）。
-- ②：把有3个魔力指示物放置的这张卡送去墓地才能发动。自己从卡组抽2张。
function c94937430.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,3)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，每次自己的额外卡组有卡加入，给这张卡放置1个魔力指示物（最多3个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c94937430.acop)
	c:RegisterEffect(e2)
	-- ②：把有3个魔力指示物放置的这张卡送去墓地才能发动。自己从卡组抽2张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(c94937430.drcon)
	e3:SetCost(c94937430.drcost)
	e3:SetTarget(c94937430.drtg)
	e3:SetOperation(c94937430.drop)
	c:RegisterEffect(e3)
end
-- 过滤条件：检查卡片是否加入到自己的额外卡组
function c94937430.cfilter(c,tp)
	return c:IsLocation(LOCATION_EXTRA) and c:IsControler(tp)
end
-- 放置指示物的效果处理：若有卡片加入到自己的额外卡组，则给这张卡放置1个魔力指示物
function c94937430.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if eg:IsExists(c94937430.cfilter,1,nil,tp) then
		c:AddCounter(0x1,1)
	end
end
-- 抽卡效果的发动条件：检查这张卡是否放置有3个魔力指示物
function c94937430.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1)==3
end
-- 抽卡效果的代价处理：检查并把这张卡送去墓地
function c94937430.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 作为发动代价，将自身送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 抽卡效果的目标处理：检查是否能抽卡，并设置目标玩家、抽卡数量及操作信息
function c94937430.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查玩家是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为2（抽卡张数）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：玩家tp抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 抽卡效果的效果处理：获取目标玩家和抽卡张数，执行抽卡
function c94937430.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
