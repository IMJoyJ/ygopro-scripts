--カラクリ解体新書
-- 效果：
-- 每次名字带有「机巧」的怪兽的表示形式变更，给这张卡放置1个机巧指示物（最多2个）。此外，可以把场上存在的这张卡送去墓地，从自己卡组抽出这张卡放置的机巧指示物数量的卡。
function c85541675.initial_effect(c)
	c:EnableCounterPermit(0x12)
	c:SetCounterLimit(0x12,2)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次名字带有「机巧」的怪兽的表示形式变更，给这张卡放置1个机巧指示物（最多2个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c85541675.accon)
	e2:SetOperation(c85541675.acop)
	c:RegisterEffect(e2)
	-- 此外，可以把场上存在的这张卡送去墓地，从自己卡组抽出这张卡放置的机巧指示物数量的卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetDescription(aux.Stringid(85541675,0))  --"抽卡"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c85541675.drcost)
	e3:SetTarget(c85541675.drtg)
	e3:SetOperation(c85541675.drop)
	c:RegisterEffect(e3)
end
c85541675.mentioned_counter={
	[0x12]=true,
}
-- 表示形式变更过滤条件：「机巧」怪兽发生的表示形式变更
function c85541675.cfilter(c)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return c:IsSetCard(0x11) and ((pp==0x1 and np==0x4) or (pp==0x4 and np==0x1) or (pp==0x8 and np==0x1))
end
-- 放置指示物条件检查：存在表示形式变更的「机巧」怪兽
function c85541675.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c85541675.cfilter,1,nil)
end
-- 放置指示物处理：给此卡放置1个机巧指示物
function c85541675.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x12,1)
end
-- 抽卡效果Cost：记录此卡上的机巧指示物数量并将此卡送去墓地
function c85541675.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	local ct=e:GetHandler():GetCounter(0x12)
	e:SetLabel(ct)
	-- 将场上的此卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 抽卡效果发动准备：检查指示物数量与玩家抽卡能力，并设置抽卡操作信息
function c85541675.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：指示物数量大于0且玩家可以抽取对应数量的卡
	if chk==0 then return c:GetCounter(0x12)>0 and Duel.IsPlayerCanDraw(tp,c:GetCounter(0x12)) end
	local ct=e:GetLabel()
	-- 设置连锁的目标玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的目标参数为发动的Cost阶段记录的指示物数量
	Duel.SetTargetParam(ct)
	-- 设置连锁操作信息：抽指定数量的卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 抽卡效果处理：从卡组抽取对应数量的卡
function c85541675.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
