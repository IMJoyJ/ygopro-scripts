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
	-- ①：只要这张卡在魔法与陷阱区域存在，每次自己抽卡阶段通常抽卡，给这张卡放置1个强欲指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c33904024.ctop)
	c:RegisterEffect(e2)
	-- ②：把有强欲指示物2个以上放置的这张卡送去墓地才能发动。自己从卡组抽2张。
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
c33904024.mentioned_counter={
	[0xd]=true,
}
-- 不入连锁的持续效果处理：当自己在抽卡阶段进行通常抽卡（规则抽卡）时，给这张卡放置1个强欲指示物。
function c33904024.ctop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp and r==REASON_RULE then
		e:GetHandler():AddCounter(0xd,1)
	end
end
-- 发动条件：这张卡放置的强欲指示物在2个以上。
function c33904024.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0xd)>=2
end
-- 发动代价：先确认这张卡可以送去墓地，再将其作为代价送去墓地。
function c33904024.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把这张卡作为发动代价送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 发动时检查自己能否抽2张卡，并设定抽卡玩家与抽卡数量及抽卡分类的操作信息。
function c33904024.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：确认自己可以抽2张卡，否则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设定为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设定为2（抽卡数量）。
	Duel.SetTargetParam(2)
	-- 设置操作信息：该效果属于抽卡分类，对象玩家为自己，预计处理抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：读取连锁设定的对象玩家与抽卡数量，让该玩家抽相应数量的卡。
function c33904024.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 读取当前连锁的对象玩家与对象参数（抽卡数量），存入变量p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡（即自己抽2张）。
	Duel.Draw(p,d,REASON_EFFECT)
end
