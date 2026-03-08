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
-- 检查场上是否存在表侧表示的「X-剑士」怪兽
function c44901281.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x100d)
end
-- 判断是否满足发动条件，即己方场上存在「X-剑士」怪兽且当前无未处理的连锁
function c44901281.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索己方场上是否存在至少1只表侧表示的「X-剑士」怪兽
	return Duel.IsExistingMatchingCard(c44901281.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 确保当前没有尚未结算的连锁环节
		and aux.NegateSummonCondition()
end
-- 设置连锁处理信息，确定将要无效召唤和破坏的怪兽
function c44901281.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将要无效召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 执行效果，使怪兽召唤无效并破坏
function c44901281.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使目标怪兽的召唤无效
	Duel.NegateSummon(eg)
	-- 以效果为破坏原因破坏目标怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
