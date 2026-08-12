--神の警告
-- 效果：
-- ①：可以支付2000基本分把以下效果发动。
-- ●包含把怪兽特殊召唤效果的怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ●自己或对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
function c84749824.initial_effect(c)
	-- ①：可以支付2000基本分把以下效果发动。●自己或对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	-- 设置发动条件为当前没有正在处理的连锁（确保在非连锁中进行的召唤之际才能发动）
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetCost(c84749824.cost1)
	e1:SetTarget(c84749824.target1)
	e1:SetOperation(c84749824.activate1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
	-- ①：可以支付2000基本分把以下效果发动。●包含把怪兽特殊召唤效果的怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(c84749824.condition2)
	e4:SetCost(c84749824.cost2)
	e4:SetTarget(c84749824.target2)
	e4:SetOperation(c84749824.activate2)
	c:RegisterEffect(e4)
end
-- 召唤·反转召唤·特殊召唤之际发动效果的Cost/支付基本分阶段
function c84749824.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000)
	-- 扣除2000基本分作为发动Cost
	else Duel.PayLPCost(tp,2000) end
end
-- 召唤·反转召唤·特殊召唤之际发动效果的Target/目标确认与操作信息设置阶段
function c84749824.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：无效怪兽的召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置当前连锁的操作信息为：破坏进行召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 召唤·反转召唤·特殊召唤之际发动效果的Operation/效果处理阶段
function c84749824.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在进行的召唤·反转召唤·特殊召唤无效
	Duel.NegateSummon(eg)
	-- 破坏那些召唤被无效的怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 包含特殊召唤效果的卡片或效果发动时效果的发动条件判定
function c84749824.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查该连锁的发动是否可以被无效，若不能则返回false
	if not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON)
end
-- 包含特殊召唤效果的卡片或效果发动时效果的Cost/支付基本分阶段
function c84749824.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000)
	-- 扣除2000基本分作为发动Cost
	else Duel.PayLPCost(tp,2000) end
end
-- 包含特殊召唤效果的卡片或效果发动时效果的Target/目标确认与操作信息设置阶段
function c84749824.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：使该卡片或效果的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置当前连锁的操作信息为：破坏该发动效果的卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 包含特殊召唤效果的卡片或效果发动时效果的Operation/效果处理阶段
function c84749824.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该连锁的发动，并确认该卡片在效果处理时仍与该效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动被无效的卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
