--王立魔法図書館
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
-- ②：把这张卡3个魔力指示物取除才能发动。自己从卡组抽1张。
function c70791313.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,3)
	-- 只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 连锁注册：记录连锁发生时此卡在场上存在
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c70791313.acop)
	c:RegisterEffect(e1)
	-- ②：把这张卡3个魔力指示物取除才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70791313,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCost(c70791313.drcost)
	e2:SetTarget(c70791313.drtg)
	e2:SetOperation(c70791313.drop)
	c:RegisterEffect(e2)
end
c70791313.mentioned_counter={
	[0x1]=true,
}
-- ①效果处理：如果是魔法卡发动且连锁时此卡在场，给此卡放置1个魔力指示物
function c70791313.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- ②效果Cost检查与处理：把这张卡3个魔力指示物取除
function c70791313.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- ②效果发动准备：设置抽1张卡的操作信息
function c70791313.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置连锁对象参数为1张
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息：让玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：从卡组抽1张卡
function c70791313.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象玩家与抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
