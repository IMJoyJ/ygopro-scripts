--ペンデュラム・ホール
-- 效果：
-- ①：自己或者对方把怪兽灵摆召唤之际才能发动。那次灵摆召唤无效，那些怪兽回到持有者卡组。
function c68477598.initial_effect(c)
	-- ①：自己或者对方把怪兽灵摆召唤之际才能发动。那次灵摆召唤无效，那些怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetCondition(c68477598.condition)
	e1:SetTarget(c68477598.target)
	e1:SetOperation(c68477598.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：用于筛选出召唤类型为灵摆召唤的怪兽
function c68477598.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 发动条件判定：判断当前是否为灵摆召唤之际且没有正在处理的连锁
function c68477598.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否处于非连锁状态，且正在召唤的怪兽中存在灵摆召唤的怪兽
	return aux.NegateSummonCondition() and eg:IsExists(c68477598.cfilter,1,nil)
end
-- 发动准备：设置无效召唤和送回卡组的操作信息
function c68477598.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效召唤，对象为正在召唤的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：送回卡组，对象为正在召唤的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,eg:GetCount(),0,0)
end
-- 效果处理：执行无效召唤并将怪兽送回卡组
function c68477598.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在进行灵摆召唤的怪兽的召唤无效
	Duel.NegateSummon(eg)
	-- 将那些召唤无效的怪兽送回持有者的卡组并洗牌
	Duel.SendtoDeck(eg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
