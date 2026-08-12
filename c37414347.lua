--F.A.シャイニングスターGT
-- 效果：
-- 机械族怪兽2只
-- 这个卡名的④的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升这张卡所连接区的「方程式运动员」怪兽的等级合计×300。
-- ②：这张卡的战斗发生的双方的战斗伤害变成0。
-- ③：「方程式运动员」魔法·陷阱卡的效果发动的场合发动。给这张卡放置1个运动员指示物。
-- ④：对方把怪兽的效果发动时，把这张卡1个运动员指示物取除才能发动。那个发动无效并破坏。
function c37414347.initial_effect(c)
	c:EnableCounterPermit(0x4a)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以2只机械族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2)
	-- ①：这张卡的攻击力上升这张卡所连接区的「方程式运动员」怪兽的等级合计×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c37414347.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡的战斗发生的双方的战斗伤害变成0。（不会给对方造成战斗伤害）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e2)
	-- ②：这张卡的战斗发生的双方的战斗伤害变成0。（自己受到的战斗伤害变成0）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：「方程式运动员」魔法·陷阱卡的效果发动的场合发动。给这张卡放置1个运动员指示物。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(37414347,0))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCondition(c37414347.ctcon)
	e4:SetTarget(c37414347.cttg)
	e4:SetOperation(c37414347.ctop)
	c:RegisterEffect(e4)
	-- ④：对方把怪兽的效果发动时，把这张卡1个运动员指示物取除才能发动。那个发动无效并破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(37414347,1))
	e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,37414347)
	e5:SetCondition(c37414347.discon)
	e5:SetCost(c37414347.discost)
	e5:SetTarget(c37414347.distg)
	e5:SetOperation(c37414347.disop)
	c:RegisterEffect(e5)
end
c37414347.mentioned_counter={
	[0x4a]=true,
}
-- 过滤器：筛选表侧表示的「方程式运动员」怪兽（等级合计计算用）
function c37414347.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107) and c:GetLevel()>=0
end
-- 计算攻击力上升数值：取这张卡所连接区表侧表示的「方程式运动员」怪兽的等级合计，乘以300作为攻击力上升值
function c37414347.atkval(e,c)
	local lg=c:GetLinkedGroup():Filter(c37414347.atkfilter,nil)
	return lg:GetSum(Card.GetLevel)*300
end
-- 发动条件：发动的效果是「方程式运动员」魔法·陷阱卡的效果
function c37414347.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(0x107)
end
-- 效果对象检查：此必发效果无需检查，并设置要放置1个运动员指示物的操作信息
function c37414347.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁处理将给这张卡放置1个运动员指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x4a)
end
-- 效果处理：这张卡与效果关联且表侧表示存在的场合，给这张卡放置1个运动员指示物
function c37414347.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:AddCounter(0x4a,1)
	end
end
-- 发动条件：对方把怪兽的效果发动，且该发动可以被无效
function c37414347.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断发动方是对方、发动的是怪兽效果且该连锁的发动可以被无效
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 发动代价：检查并实际把这张卡1个运动员指示物取除作为代价
function c37414347.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0x4a,1,REASON_COST) end
	c:RemoveCounter(tp,0x4a,1,REASON_COST)
end
-- 效果对象检查：设置使发动无效的操作信息，若发动的卡与效果关联则追加破坏的操作信息
function c37414347.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁处理将使该效果的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：本次连锁处理将破坏那只发动效果的怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使对方怪兽效果的发动无效，若成功且该卡与效果关联则将其破坏
function c37414347.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效，并确认发动的卡仍与效果关联（在场上存在）
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果的原因将那只发动效果的怪兽破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
