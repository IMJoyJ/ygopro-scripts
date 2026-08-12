--鉄騎の雷鎚
-- 效果：
-- ①：场上的怪兽的效果·魔法·陷阱卡发动时，把基本分支付一半才能发动。那个发动无效并破坏。那之后，和破坏的卡存在过的区域相同纵列的怪兽区域·魔法与陷阱区域有卡存在的场合，那些卡全部破坏。
local s,id,o=GetID()
-- 注册两个连锁触发效果，分别对应怪兽效果和魔法陷阱卡的发动
function s.initial_effect(c)
	-- 创建一个用于怪兽效果发动时的连锁效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.moncon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 创建一个用于魔法陷阱卡发动时的连锁效果
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.accon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
-- 支付一半基本分作为发动cost
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前玩家基本分的一半
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 判断连锁是否为怪兽区域发动的效果
function s.moncon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁发动的位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 发动位置为怪兽区域且为怪兽效果，且该连锁可被无效
	return loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 判断连锁是否为魔法或陷阱卡的发动
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	-- 发动为魔法或陷阱卡且该连锁可被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 设置效果处理时的操作信息，包括使发动无效和破坏
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏发动卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 处理效果发动时的破坏与连锁破坏逻辑
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local dg=rc:GetColumnGroup()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then dg:RemoveCard(c) end
	-- 使连锁发动无效并确认发动卡存在且与效果相关
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re)
		-- 确认发动卡被破坏且同列区域有卡存在
		and Duel.Destroy(eg,REASON_EFFECT)~=0 and dg:GetCount()>0 then
		-- 中断当前效果处理，避免同时处理多个效果
		Duel.BreakEffect()
		-- 破坏与发动卡同列区域的卡
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
