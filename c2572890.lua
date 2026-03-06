--マジェスペクター・テンペスト
-- 效果：
-- ①：可以把自己场上1只魔法师族·风属性怪兽解放把以下效果发动。
-- ●怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ●自己或者对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
function c2572890.initial_effect(c)
	-- 效果原文内容：①：可以把自己场上1只魔法师族·风属性怪兽解放把以下效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	-- 规则层面作用：判断当前是否存在尚未结算的连锁环节，确保效果只能在非连锁状态下发动。
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetCost(c2572890.cost)
	e1:SetTarget(c2572890.target1)
	e1:SetOperation(c2572890.activate1)
	c:RegisterEffect(e1)
	-- 效果原文内容：●怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c2572890.condition2)
	e2:SetCost(c2572890.cost)
	e2:SetTarget(c2572890.target2)
	e2:SetOperation(c2572890.activate2)
	c:RegisterEffect(e2)
end
-- 规则层面作用：定义满足条件的可解放怪兽过滤器，必须是魔法师族、风属性且未在战斗中被破坏。
function c2572890.cfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
		and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 规则层面作用：支付效果的解放费用，检查并选择场上符合条件的1只怪兽进行解放。
function c2572890.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否满足解放条件，即场上是否存在符合条件的怪兽可被解放。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c2572890.cfilter,1,nil) end
	-- 规则层面作用：从场上选择1张符合条件的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c2572890.cfilter,1,1,nil)
	-- 规则层面作用：将选中的怪兽以代價原因进行解放。
	Duel.Release(g,REASON_COST)
end
-- 规则层面作用：设置效果处理时要执行的操作信息，包括无效召唤和破坏。
function c2572890.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置连锁操作信息，表示将要无效召唤。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 规则层面作用：设置连锁操作信息，表示将要破坏怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 规则层面作用：执行效果的主要操作，使召唤无效并破坏相关怪兽。
function c2572890.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：使正在召唤的怪兽召唤无效。
	Duel.NegateSummon(eg)
	-- 规则层面作用：破坏被召唤的怪兽。
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 效果原文内容：●自己或者对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
function c2572890.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断效果发动时是否为怪兽类型的召唤，并且该连锁可以被无效。
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 规则层面作用：设置第二效果的目标信息，包括无效发动和可能的破坏。
function c2572890.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置连锁操作信息，表示将要使发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面作用：设置连锁操作信息，表示将要破坏怪兽。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 规则层面作用：执行第二效果的主要操作，使发动无效并破坏相关怪兽。
function c2572890.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断是否成功使发动无效，并且目标怪兽仍然有效。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面作用：破坏被无效发动所影响的怪兽。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
