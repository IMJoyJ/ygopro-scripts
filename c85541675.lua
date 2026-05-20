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
-- 过滤条件：名字带有「机巧」的怪兽且表示形式发生了变更（表侧攻击与表侧守备互相变更，或里侧守备变为表侧攻击）
function c85541675.cfilter(c)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return c:IsSetCard(0x11) and ((pp==0x1 and np==0x4) or (pp==0x4 and np==0x1) or (pp==0x8 and np==0x1))
end
-- 放置指示物效果的发动条件：发生表示形式变更的怪兽中存在满足过滤条件的「机巧」怪兽
function c85541675.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c85541675.cfilter,1,nil)
end
-- 放置指示物效果的处理：给这张卡放置1个机巧指示物
function c85541675.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x12,1)
end
-- 抽卡效果的代价：确认这张卡可以送去墓地，记录当前这张卡上的机巧指示物数量，并将这张卡送去墓地
function c85541675.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	local ct=e:GetHandler():GetCounter(0x12)
	e:SetLabel(ct)
	-- 将这张卡送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 抽卡效果的发动准备：确认这张卡上有指示物且玩家可以抽对应数量的卡，设置目标玩家和抽卡数量，并声明操作信息
function c85541675.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动检测：确认这张卡上至少有1个机巧指示物，且自己可以从卡组抽对应数量的卡
	if chk==0 then return c:GetCounter(0x12)>0 and Duel.IsPlayerCanDraw(tp,c:GetCounter(0x12)) end
	local ct=e:GetLabel()
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为之前记录的指示物数量
	Duel.SetTargetParam(ct)
	-- 设置当前连锁的操作信息为：自己抽对应指示物数量的卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 抽卡效果的处理：获取目标玩家和抽卡数量，执行抽卡
function c85541675.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽对应数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
