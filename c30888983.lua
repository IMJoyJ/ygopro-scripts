--方舟の選別
-- 效果：
-- ①：自己或者对方把怪兽召唤·反转召唤·特殊召唤之际支付1000基本分才能发动。场上有相同种族的怪兽存在的怪兽的召唤·反转召唤·特殊召唤无效，那些怪兽破坏。
function c30888983.initial_effect(c)
	-- 效果原文内容：①：自己或者对方把怪兽召唤·反转召唤·特殊召唤之际支付1000基本分才能发动。场上有相同种族的怪兽存在的怪兽的召唤·反转召唤·特殊召唤无效，那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(c30888983.condition)
	e1:SetCost(c30888983.cost)
	e1:SetTarget(c30888983.target)
	e1:SetOperation(c30888983.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
end
-- 效果作用：检查指定种族的怪兽是否在场上表侧表示存在
function c30888983.cfilter(c,rc)
	return c:IsFaceup() and c:IsRace(rc)
end
-- 效果作用：判断是否有怪兽在召唤·反转召唤·特殊召唤时，场上有相同种族的怪兽存在
function c30888983.filter(c)
	-- 效果作用：检索满足条件的卡片组
	return Duel.IsExistingMatchingCard(c30888983.cfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetRace())
end
-- 效果作用：判断是否满足发动条件
function c30888983.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断当前是否存在尚未结算的连锁环节且有符合条件的怪兽
	return aux.NegateSummonCondition() and eg:IsExists(c30888983.filter,1,nil)
end
-- 效果作用：支付1000基本分的费用
function c30888983.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 效果作用：让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果作用：设置连锁操作信息
function c30888983.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c30888983.filter,nil)
	-- 效果作用：设置无效召唤的效果分类
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	-- 效果作用：设置破坏的效果分类
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用：执行效果处理
function c30888983.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c30888983.filter,nil)
	-- 效果作用：使目标怪兽的召唤无效
	Duel.NegateSummon(g)
	-- 效果作用：以效果为原因破坏目标怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
