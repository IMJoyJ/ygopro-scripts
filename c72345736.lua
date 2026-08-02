--六武衆の結束
-- 效果：
-- ①：每次「六武众」怪兽召唤·特殊召唤给这张卡放置1个武士道指示物（最多2个）。
-- ②：把有武士道指示物放置的这张卡送去墓地才能发动。自己从卡组抽出这张卡放置的武士道指示物的数量。
function c72345736.initial_effect(c)
	c:EnableCounterPermit(0x3)
	c:SetCounterLimit(0x3,2)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次「六武众」怪兽召唤·特殊召唤给这张卡放置1个武士道指示物（最多2个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c72345736.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：把有武士道指示物放置的这张卡送去墓地才能发动。自己从卡组抽出这张卡放置的武士道指示物的数量。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetDescription(aux.Stringid(72345736,0))  --"抽卡"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c72345736.drcost)
	e4:SetTarget(c72345736.drtg)
	e4:SetOperation(c72345736.drop)
	c:RegisterEffect(e4)
end
c72345736.counter_add_list={0x3}
c72345736.mentioned_counter={
	[0x3]=true,
}
-- 检查卡片是否为表侧表示的「六武众」卡
function c72345736.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 检查是否有「六武众」怪兽召唤或特殊召唤，如果有则给这张卡放置1个武士道指示物
function c72345736.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c72345736.ctfilter,1,nil) then
		e:GetHandler():AddCounter(0x3,1)
	end
end
-- 检查这张卡是否能作为代价送去墓地，如果能则记录指示物数量并将此卡送去墓地
function c72345736.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	local ct=e:GetHandler():GetCounter(0x3)
	e:SetLabel(ct)
	-- 把这张卡作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 检查此卡是否有指示物且玩家是否能抽出对应数量的卡，并设置抽卡的操作信息
function c72345736.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查此卡是否有武士道指示物以及玩家能否抽出对应数量的卡片
	if chk==0 then return c:GetCounter(0x3)>0 and Duel.IsPlayerCanDraw(tp,c:GetCounter(0x3)) end
	local ct=e:GetLabel()
	-- 将当前玩家设置为抽卡对象
	Duel.SetTargetPlayer(tp)
	-- 将刚才记录的指示物数量设置为抽卡数量的参数
	Duel.SetTargetParam(ct)
	-- 设置操作信息：包含抽卡的效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 执行从卡组抽出对应数量卡片的操作
function c72345736.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽出对应数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
