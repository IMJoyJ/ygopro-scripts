--ブローニング・パワー
-- 效果：
-- 把自己场上存在的1只念动力族怪兽解放发动。魔法·陷阱卡的发动、怪兽的召唤·特殊召唤的其中1个无效并破坏。
function c59718521.initial_effect(c)
	-- 把自己场上存在的1只念动力族怪兽解放发动。怪兽的召唤·特殊召唤的其中1个无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	-- 设置效果发动条件为当前没有正在处理的连锁（即只能在非连锁状态下应对召唤/特殊召唤）
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetCost(c59718521.cost)
	e1:SetTarget(c59718521.target1)
	e1:SetOperation(c59718521.activate1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e2)
	-- 把自己场上存在的1只念动力族怪兽解放发动。魔法·陷阱卡的发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(c59718521.condition2)
	e3:SetCost(c59718521.cost)
	e3:SetTarget(c59718521.target2)
	e3:SetOperation(c59718521.activate2)
	c:RegisterEffect(e3)
end
-- 过滤场上未确定被战斗破坏的念动力族怪兽
function c59718521.filter(c)
	return c:IsRace(RACE_PSYCHO) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 发动代价：解放自己场上1只念动力族怪兽
function c59718521.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放的念动力族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c59718521.filter,1,nil) end
	-- 玩家选择1只可解放的念动力族怪兽
	local g=Duel.SelectReleaseGroup(tp,c59718521.filter,1,1,nil)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 召唤/特殊召唤无效效果的发动准备（设置操作信息）
function c59718521.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：包含无效召唤分类，目标为正在召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：包含破坏分类，目标为正在召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 召唤/特殊召唤无效效果的处理：无效召唤并破坏
function c59718521.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 使怪兽的召唤/特殊召唤无效
	Duel.NegateSummon(eg)
	-- 破坏该召唤被无效的怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 魔法·陷阱卡发动无效效果的发动条件：对方发动了魔法·陷阱卡，且该发动可以被无效
function c59718521.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁是否为魔法·陷阱卡的发动，且该发动是否可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 魔法·陷阱卡发动无效效果的发动准备（设置操作信息）
function c59718521.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：包含无效发动分类
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：包含破坏分类，目标为被无效发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 魔法·陷阱卡发动无效效果的处理：无效发动并破坏
function c59718521.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使该魔法·陷阱卡的发动无效，且该卡在场上/存在关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动被无效的魔法·陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
