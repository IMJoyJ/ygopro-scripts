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
	-- 可以把场上存在的这张卡送去墓地，从自己卡组抽出这张卡放置的机巧指示物数量的卡。
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
-- 检查该卡是否为名字带有「机巧」的怪兽，并且发生表示形式变更
function c85541675.cfilter(c)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return c:IsSetCard(0x11) and ((pp==0x1 and np==0x4) or (pp==0x4 and np==0x1) or (pp==0x8 and np==0x1))
end
-- 检查是否有满足条件的怪兽表示形式发生变更
function c85541675.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c85541675.cfilter,1,nil)
end
-- 给这张卡放置1个机巧指示物
function c85541675.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x12,1)
end
-- 检查这张卡能否作为代价送去墓地，获取指示物数量，并将这张卡送去墓地
function c85541675.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	local ct=e:GetHandler():GetCounter(0x12)
	e:SetLabel(ct)
	-- 将这张卡作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 检查是否有指示物且玩家是否可以抽卡，设置连锁的对象玩家和参数，并设置抽卡的效果操作信息
function c85541675.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查这张卡上的机巧指示物是否大于0且玩家是否可以抽出指示物数量的卡
	if chk==0 then return c:GetCounter(0x12)>0 and Duel.IsPlayerCanDraw(tp,c:GetCounter(0x12)) end
	local ct=e:GetLabel()
	-- 把当前正在处理的连锁的对象玩家设置成发动玩家
	Duel.SetTargetPlayer(tp)
	-- 把当前正在处理的连锁的对象参数设置成指示物的数量
	Duel.SetTargetParam(ct)
	-- 设置包含抽卡的效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 获取连锁的对象玩家和参数，并让该玩家抽卡
function c85541675.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的对象玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家抽出对应数量的卡片
	Duel.Draw(p,d,REASON_EFFECT)
end
