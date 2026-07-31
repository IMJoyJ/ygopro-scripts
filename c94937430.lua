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
c94937430.mentioned_counter={
	[0x1]=true,
}
-- 放置指示物条件过滤：卡片加入到自己额外卡组
function c94937430.cfilter(c,tp)
	return c:IsLocation(LOCATION_EXTRA) and c:IsControler(tp)
end
-- ①效果处理：额外卡组有卡加入时给此卡放置1个魔力指示物
function c94937430.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if eg:IsExists(c94937430.cfilter,1,nil,tp) then
		c:AddCounter(0x1,1)
	end
end
-- ②效果发动条件检查：此卡上的魔力指示物刚好为3个
function c94937430.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1)==3
end
-- 抽卡效果Cost：把放置有3个指示物的此卡送去墓地
function c94937430.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡作为Cost送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 抽卡效果发动准备：设定抽卡目标玩家与数量，设置连锁操作信息
function c94937430.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设定效果生效目标玩家为自身
	Duel.SetTargetPlayer(tp)
	-- 设定抽卡参数为2张
	Duel.SetTargetParam(2)
	-- 设置连锁操作信息：玩家从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 抽卡效果处理：目标玩家从卡组抽2张卡
function c94937430.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家与抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡处理
	Duel.Draw(p,d,REASON_EFFECT)
end
