--昇天の黒角笛
-- 效果：
-- ①：对方只把怪兽1只特殊召唤之际才能发动。那次特殊召唤无效，那只怪兽破坏。
function c50323155.initial_effect(c)
	-- ①：对方只把怪兽1只特殊召唤之际才能发动。那次特殊召唤无效，那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetCondition(c50323155.condition)
	e1:SetTarget(c50323155.target)
	e1:SetOperation(c50323155.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：判断是否满足发动时机，即对方特殊召唤且不是自己操作、特殊召唤的怪兽仅为1只、且当前没有连锁处理中。
function c50323155.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 条件表达式：对方回合玩家不等于特殊召唤玩家（即对方特殊召唤）、特殊召唤的怪兽数量为1、且当前无连锁处理（允许发动无效召唤）。
	return tp~=ep and eg:GetCount()==1 and aux.NegateSummonCondition()
end
-- 目标函数：本效果不取对象，满足发动条件时直接通过，并预设本次处理将无效特殊召唤并破坏那只怪兽。
function c50323155.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：向连锁登记本次效果将无效特殊召唤，对象为本次特殊召唤的怪兽组eg，数量为eg:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：向连锁登记本次效果将破坏对象，对象为本次特殊召唤的怪兽组eg，数量为eg:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 效果处理函数：实际执行使这次特殊召唤无效，并将那只怪兽破坏。
function c50323155.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使eg（本次特殊召唤的怪兽）的特殊召唤无效。
	Duel.NegateSummon(eg)
	-- 以效果原因将eg（被无效召唤的怪兽）破坏。
	Duel.Destroy(eg,REASON_EFFECT)
end
