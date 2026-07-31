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
-- 当玩家在抽卡阶段通常抽卡时，若抽卡原因来自规则（REASON_RULE），则给该卡放置1个强欲指示物。
function c33904024.ctop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp and r==REASON_RULE then
		e:GetHandler():AddCounter(0xd,1)
	end
end
-- 效果发动的条件：该卡的强欲指示物数量大于等于2。
function c33904024.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0xd)>=2
end
-- 将该卡送入墓地作为发动此效果的代价。
function c33904024.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 以效果原因将该卡送入墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置效果的目标玩家为使用者，并设定抽卡数量为2张。
function c33904024.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁处理时的目标玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理时的目标参数为2（表示抽2张卡）。
	Duel.SetTargetParam(2)
	-- 设置效果操作信息为抽卡效果，目标为当前玩家，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行效果操作：让指定玩家从卡组抽指定数量的卡。
function c33904024.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家以效果原因抽指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
