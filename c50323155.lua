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
-- 判断是否为对方特殊召唤且仅召唤1只怪兽，并确保当前无未处理的连锁。
function c50323155.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方玩家与发动玩家不同，且此次特殊召唤的怪兽数量为1，同时满足无未处理连锁条件。
	return tp~=ep and eg:GetCount()==1 and aux.NegateSummonCondition()
end
-- 设置效果的目标为本次特殊召唤的怪兽，准备无效召唤和破坏操作。
function c50323155.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将本次特殊召唤无效（CATEGORY_DISABLE_SUMMON）
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：破坏本次特殊召唤的怪兽（CATEGORY_DESTROY）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 执行效果：使特殊召唤无效并破坏该怪兽。
function c50323155.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使本次特殊召唤无效
	Duel.NegateSummon(eg)
	-- 以效果为原因破坏该怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
