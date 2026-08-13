--セイバー・ホール
-- 效果：
-- ①：自己场上有「X-剑士」怪兽存在，自己或对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
function c44901281.initial_effect(c)
	-- ①：自己场上有「X-剑士」怪兽存在，自己或对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(c44901281.condition)
	e1:SetTarget(c44901281.target)
	e1:SetOperation(c44901281.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选表侧表示且属于「X-剑士」系列的怪兽。
function c44901281.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x100d)
end
-- 发动条件：自己场上有表侧表示的「X-剑士」怪兽，且当前没有处理中的连锁（满足召唤无效类效果的发动时机）。
function c44901281.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示且属于「X-剑士」系列的怪兽。
	return Duel.IsExistingMatchingCard(c44901281.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且当前没有处于连锁处理中（召唤无效类效果只能在无连锁处理时发动）。
		and aux.NegateSummonCondition()
end
-- 效果发动时的目标处理：不取对象，登记无效召唤与破坏的操作信息后即可发动。
function c44901281.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本效果包含无效召唤，对象为当前召唤/特殊召唤/反转召唤的怪兽组（eg），数量为eg的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：本效果包含破坏，对象为当前召唤的怪兽组（eg），数量为eg的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 效果处理：使召唤无效，并将那些怪兽破坏。
function c44901281.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在进行的召唤/反转召唤/特殊召唤无效（eg为被无效的怪兽组）。
	Duel.NegateSummon(eg)
	-- 以效果为原因将这些被无效召唤的怪兽破坏。
	Duel.Destroy(eg,REASON_EFFECT)
end
