--ファイヤークラッカー
-- 效果：
-- 「爆竹鬼」的①的效果1回合只能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。给与对方1000伤害，下次的自己抽卡阶段跳过。这个效果在对方回合也能发动。
-- ②：只要这张卡在怪兽区域存在，每次对方受到效果伤害给这张卡放置1个指示物。
-- ③：自己·对方的结束阶段发动。这张卡的指示物全部取除，给与对方那个数量×300伤害。
function c81109178.initial_effect(c)
	c:EnableCounterPermit(0x42)
	-- 「爆竹鬼」的①的效果1回合只能使用1次。①：把这张卡从手卡丢弃才能发动。给与对方1000伤害，下次的自己抽卡阶段跳过。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81109178,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,81109178)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c81109178.damcost1)
	e1:SetTarget(c81109178.damtg1)
	e1:SetOperation(c81109178.damop1)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次对方受到效果伤害给这张卡放置1个指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c81109178.ctcon)
	e2:SetOperation(c81109178.ctop)
	c:RegisterEffect(e2)
	-- ③：自己·对方的结束阶段发动。这张卡的指示物全部取除，给与对方那个数量×300伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81109178,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c81109178.damtg2)
	e3:SetOperation(c81109178.damop2)
	c:RegisterEffect(e3)
end
-- 1号效果的发动代价（把这张卡从手卡丢弃）
function c81109178.damcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡作为代价从手卡丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 1号效果的发动准备（设置对方为伤害对象，伤害数值为1000）
function c81109178.damtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置对方玩家为效果处理对象
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值为1000
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为给与对方1000点效果伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 1号效果的效果处理（给与对方1000伤害，并注册跳过下次自己抽卡阶段的效果）
function c81109178.damop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 如果成功给与对方效果伤害
	if Duel.Damage(p,d,REASON_EFFECT)~=0 then
		-- 下次的自己抽卡阶段跳过。②：只要这张卡在怪兽区域存在，每次对方受到效果伤害给这张卡放置1个指示物。③：自己·对方的结束阶段发动。这张卡的指示物全部取除，给与对方那个数量×300伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_SKIP_DP)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
		-- 给玩家注册跳过下次抽卡阶段的效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 2号效果的发动条件（对方因效果受到伤害时）
function c81109178.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and bit.band(r,REASON_EFFECT)~=0
end
-- 2号效果的效果处理（给这张卡放置1个指示物）
function c81109178.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x42,1)
end
-- 3号效果的发动准备（获取指示物数量，设置对方为伤害对象，伤害数值为指示物数量）
function c81109178.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetHandler():GetCounter(0x42)
	-- 设置对方玩家为效果处理对象
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值为指示物数量
	Duel.SetTargetParam(ct)
	-- 设置当前连锁的操作信息为给与对方伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct)
end
-- 3号效果的效果处理（取除这张卡所有的指示物，给与对方那个数量×300伤害）
function c81109178.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和指示物数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x42)
	if c:RemoveCounter(tp,0x42,ct,REASON_EFFECT) then
		-- 给与对方取除指示物数量×300的效果伤害
		Duel.Damage(p,ct*300,REASON_EFFECT)
	end
end
