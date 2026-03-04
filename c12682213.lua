--鉄騎の雷鎚
-- 效果：
-- ①：场上的怪兽的效果·魔法·陷阱卡发动时，把基本分支付一半才能发动。那个发动无效并破坏。那之后，和破坏的卡存在过的区域相同纵列的怪兽区域·魔法与陷阱区域有卡存在的场合，那些卡全部破坏。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	-- ①：场上的怪兽的效果·魔法·陷阱卡发动时，把基本分支付一半才能发动。那个发动无效并破坏。那之后，和破坏的卡存在过的区域相同纵列的怪兽区域·魔法与陷阱区域有卡存在的场合，那些卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.moncon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ①：场上的怪兽的效果·魔法·陷阱卡发动时，把基本分支付一半才能发动。那个发动无效并破坏。那之后，和破坏的卡存在过的区域相同纵列的怪兽区域·魔法与陷阱区域有卡存在的场合，那些卡全部破坏。
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
-- 支付LP费用函数
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前玩家生命值的一半
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 怪兽效果发动条件函数
function s.moncon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 发动位置为怪兽区域且为怪兽卡效果发动且可无效
	return loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 魔法陷阱卡发动条件函数
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	-- 发动为魔法或陷阱卡且可无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 效果处理目标设置函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果发动处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local dg=rc:GetColumnGroup()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then dg:RemoveCard(c) end
	-- 使连锁发动无效并判断破坏对象是否有效
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re)
		-- 判断是否满足破坏列中卡片的条件
		and Duel.Destroy(eg,REASON_EFFECT)~=0 and dg:GetCount()>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 破坏列中所有卡片
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
