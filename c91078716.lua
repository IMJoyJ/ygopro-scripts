--ポリノシス
-- 效果：
-- 把自己场上存在的1只植物族怪兽解放发动。魔法·陷阱卡的发动、怪兽的召唤·特殊召唤的其中1个无效并破坏。
function c91078716.initial_effect(c)
	-- 把自己场上存在的1只植物族怪兽解放发动。……怪兽的召唤·特殊召唤的其中1个无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	-- 设置效果发动的条件为当前没有正在处理的连锁（即只能在非连锁状态下的召唤之际发动）
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetCost(c91078716.cost)
	e1:SetTarget(c91078716.target1)
	e1:SetOperation(c91078716.activate1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e2)
	-- 把自己场上存在的1只植物族怪兽解放发动。魔法·陷阱卡的发动……无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(c91078716.condition2)
	e3:SetCost(c91078716.cost)
	e3:SetTarget(c91078716.target2)
	e3:SetOperation(c91078716.activate2)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选自己场上未确定被战斗破坏的植物族怪兽
function c91078716.filter(c)
	return c:IsRace(RACE_PLANT) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 发动代价：解放自己场上1只植物族怪兽
function c91078716.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足过滤条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c91078716.filter,1,nil) end
	-- 让玩家选择1只满足过滤条件的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c91078716.filter,1,1,nil)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 设置召唤无效效果的发动目标和操作信息
function c91078716.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示此效果包含“无效召唤”分类，目标为正在召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置连锁操作信息，表示此效果包含“破坏”分类，目标为正在召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 召唤无效效果的实际处理：使召唤无效并破坏该怪兽
function c91078716.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在进行的怪兽召唤无效
	Duel.NegateSummon(eg)
	-- 将召唤被无效的怪兽破坏
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 设置魔陷发动无效效果的发动条件
function c91078716.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断被响应的效果是否为魔法·陷阱卡的发动，且该发动可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 设置魔陷发动无效效果的发动目标和操作信息
function c91078716.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示此效果包含“使发动无效”分类
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁操作信息，表示此效果包含“破坏”分类，目标为被无效发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 魔陷发动无效效果的实际处理：使发动无效并破坏该卡
function c91078716.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该魔法·陷阱卡的发动无效，且该卡在场上或原位置存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动被无效的魔法·陷阱卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
