--強欲なカケラ
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，每次自己抽卡阶段通常抽卡，给这张卡放置1个强欲指示物。
-- ②：把有强欲指示物2个以上放置的这张卡送去墓地才能发动。自己从卡组抽2张。
function c33904024.initial_effect(c)
	c:EnableCounterPermit(0xd)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：只要这张卡在魔法与陷阱区域存在，每次自己抽卡阶段通常抽卡，给这张卡放置1个强欲指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c33904024.ctop)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：把有强欲指示物2个以上放置的这张卡送去墓地才能发动。自己从卡组抽2张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33904024,0))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c33904024.drcon)
	e3:SetCost(c33904024.drcost)
	e3:SetTarget(c33904024.drtg)
	e3:SetOperation(c33904024.drop)
	c:RegisterEffect(e3)
end
-- 规则层面操作：当玩家在抽卡阶段通常抽卡时，给这张卡放置1个强欲指示物。
function c33904024.ctop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp and r==REASON_RULE then
		e:GetHandler():AddCounter(0xd,1)
	end
end
-- 规则层面操作：判断是否满足发动条件，即强欲指示物数量大于等于2。
function c33904024.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0xd)>=2
end
-- 规则层面操作：支付发动费用，将此卡送入墓地。
function c33904024.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 规则层面操作：将此卡送入墓地作为费用。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 规则层面操作：设置效果目标为自身玩家，设置抽卡数量为2，并设置操作信息。
function c33904024.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 规则层面操作：设置连锁效果的目标玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 规则层面操作：设置连锁效果的目标参数为2。
	Duel.SetTargetParam(2)
	-- 规则层面操作：设置连锁效果的操作信息为抽卡效果，目标为当前玩家，抽卡数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 规则层面操作：执行效果，使当前玩家从卡组抽2张卡。
function c33904024.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取连锁效果的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面操作：使指定玩家从卡组抽指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
