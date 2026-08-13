--バスター・スラッシュ
-- 效果：
-- 自己场上有名字带有「/爆裂体」的怪兽表侧表示存在的场合才能发动。场上表侧表示存在的怪兽全部破坏。
function c40012727.initial_effect(c)
	-- 自己场上有名字带有「/爆裂体」的怪兽表侧表示存在的场合才能发动。场上表侧表示存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c40012727.condition)
	e1:SetTarget(c40012727.target)
	e1:SetOperation(c40012727.activate)
	c:RegisterEffect(e1)
end
-- c40012727.cfilter：用于筛选“自己场上表侧表示且卡名含有「/爆裂体」的怪兽”的过滤函数。
function c40012727.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x104f)
end
-- c40012727.condition：发动条件判断函数，检查自己场上是否存在至少1只表侧表示的名字带有「/爆裂体」的怪兽。
function c40012727.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 执行检索，检查以tp方视角自己的主要怪兽区是否存在至少1只满足cfilter条件的「/爆裂体」怪兽。
	return Duel.IsExistingMatchingCard(c40012727.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- c40012727.filter：用于筛选场上表侧表示怪兽的过滤函数，作为被破坏对象的判定条件。
function c40012727.filter(c)
	return c:IsFaceup()
end
-- c40012727.target：效果发动时的目标处理函数，负责合法性确认并设置本次破坏的操作信息。
function c40012727.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查场上是否存在至少1只表侧表示怪兽，确保有可被破坏的对象（该效果不取对象）。
	if chk==0 then return Duel.IsExistingMatchingCard(c40012727.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得场上所有表侧表示怪兽的集合，作为发动时确认的要被破坏的候选卡。
	local dg=Duel.GetMatchingGroup(c40012727.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：将破坏分类（CATEGORY_DESTROY）和对象集合dg及数量告知系统，供连锁中相关效果（如星尘龙等）进行响应检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- c40012727.activate：效果结算时的处理函数，实际执行对场上表侧表示怪兽的破坏。
function c40012727.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取当前场上所有表侧表示怪兽的集合，以处理时场上的实际状态为准。
	local dg=Duel.GetMatchingGroup(c40012727.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因（REASON_EFFECT）将集合dg中的所有怪兽全部破坏。
	Duel.Destroy(dg,REASON_EFFECT)
end
