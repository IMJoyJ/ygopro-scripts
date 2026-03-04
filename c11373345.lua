--無力の証明
-- 效果：
-- 自己场上有7星以上的怪兽表侧表示存在的场合才能发动。对方场上表侧表示存在的5星以下的怪兽全部破坏。这张卡发动的回合，自己场上存在的怪兽不能攻击。
function c11373345.initial_effect(c)
	-- 效果原文内容：自己场上有7星以上的怪兽表侧表示存在的场合才能发动。对方场上表侧表示存在的5星以下的怪兽全部破坏。这张卡发动的回合，自己场上存在的怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c11373345.condition)
	e1:SetCost(c11373345.cost)
	e1:SetTarget(c11373345.target)
	e1:SetOperation(c11373345.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查场上是否存在表侧表示且等级为7以上的怪兽
function c11373345.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7)
end
-- 效果条件函数，判断是否满足发动条件
function c11373345.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只等级7以上的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c11373345.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果费用函数，设置发动时的费用
function c11373345.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在当前回合中是否已经进行过攻击动作
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- 效果原文内容：自己场上有7星以上的怪兽表侧表示存在的场合才能发动。对方场上表侧表示存在的5星以下的怪兽全部破坏。这张卡发动的回合，自己场上存在的怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能攻击效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数，检查场上是否存在表侧表示且等级为5以下的怪兽
function c11373345.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(5)
end
-- 效果目标函数，设置效果处理时的目标
function c11373345.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只等级5以下的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c11373345.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有满足条件的怪兽组
	local sg=Duel.GetMatchingGroup(c11373345.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果发动函数，执行效果的主要处理
function c11373345.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足条件的怪兽组
	local sg=Duel.GetMatchingGroup(c11373345.filter,tp,0,LOCATION_MZONE,nil)
	-- 将满足条件的怪兽全部破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
