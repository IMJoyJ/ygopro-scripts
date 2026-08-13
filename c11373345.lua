--無力の証明
-- 效果：
-- 自己场上有7星以上的怪兽表侧表示存在的场合才能发动。对方场上表侧表示存在的5星以下的怪兽全部破坏。这张卡发动的回合，自己场上存在的怪兽不能攻击。
function c11373345.initial_effect(c)
	-- 自己场上有7星以上的怪兽表侧表示存在的场合才能发动。对方场上表侧表示存在的5星以下的怪兽全部破坏。这张卡发动的回合，自己场上存在的怪兽不能攻击。
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
-- 过滤条件：判定怪兽是否为表侧表示且等级在7星以上（即7星及以上）。
function c11373345.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7)
end
-- 发动条件判定：确认自己场上存在至少1张满足cfilter过滤条件的怪兽（即表侧表示且等级7星以上）。
function c11373345.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以我方视角看，我方怪兽区域是否存在至少1张满足cfilter条件的表侧表示7星以上怪兽。
	return Duel.IsExistingMatchingCard(c11373345.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 作为发动代价兼发动时的自肃效果：确认本回合自己尚未进行过攻击，然后给自己场上所有怪兽附加‘不能攻击’的效果，该效果持续到回合结束，且无法被免疫。
function c11373345.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己在本回合的攻击次数为0，即还未攻击过才能发动。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- 对方场上表侧表示存在的5星以下的怪兽全部破坏。这张卡发动的回合，自己场上存在的怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将‘自己场上怪兽不能攻击’的效果注册到决斗中，持续到结束阶段，适用于己方怪兽区域。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：判定怪兽是否为表侧表示且等级在5星以下（即5星及以下）。
function c11373345.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(5)
end
-- 发动时进行合法性与操作信息设置：确认对方场上存在符合条件的表侧表示5星以下怪兽，并登记所有此类怪兽为破坏对象信息（不取对象）。
function c11373345.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时机检查：确认对方场上存在至少1张表侧表示且等级5星以下的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c11373345.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方场上所有表侧表示且等级5星以下的怪兽作为集合，用于设置操作信息（不作为取对象指定）。
	local sg=Duel.GetMatchingGroup(c11373345.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：将sg中的怪兽全部登记为将被破坏的卡片，数量为sg的数量，用于连锁处理时记录破坏分类。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理：选取对方场上所有表侧表示且等级5星以下的怪兽，并全部破坏。
function c11373345.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新取得对方场上所有表侧表示且等级5星以下的怪兽。
	local sg=Duel.GetMatchingGroup(c11373345.filter,tp,0,LOCATION_MZONE,nil)
	-- 以效果理由将这些怪兽全部破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
