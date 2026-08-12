--誘惑のシャドウ
-- 效果：
-- 对方场上有怪兽被盖放时才能发动。那1只盖放的怪兽变成表侧攻击表示。（这个时候，反转效果怪兽的效果不发动。）
function c58621589.initial_effect(c)
	-- 对方场上有怪兽被盖放时才能发动。那1只盖放的怪兽变成表侧攻击表示。（这个时候，反转效果怪兽的效果不发动。）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetTarget(c58621589.target)
	e1:SetOperation(c58621589.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_MSET)
	e2:SetTarget(c58621589.target2)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c58621589.target2)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选对方场上由表侧表示变为里侧表示的怪兽
function c58621589.filter1(c,tp)
	return c:IsFacedown() and c:IsPreviousPosition(POS_FACEUP) and c:IsControler(1-tp)
end
-- 表示形式变更时的发动目标：确认对方场上是否有怪兽被盖放，并将其设为效果处理对象
function c58621589.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c58621589.filter1,1,nil,tp) end
	-- 将触发效果的怪兽设为效果处理对象
	Duel.SetTargetCard(eg)
	-- 设置操作信息：改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
end
-- 过滤函数：筛选对方场上里侧表示的怪兽
function c58621589.filter2(c,tp)
	return c:IsFacedown() and c:IsControler(1-tp)
end
-- 怪兽放置或里侧特殊召唤时的发动目标：确认对方场上是否有怪兽被盖放，并将其设为效果处理对象
function c58621589.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c58621589.filter2,1,nil,tp) end
	-- 将新盖放的怪兽设为效果处理对象
	Duel.SetTargetCard(eg)
	-- 设置操作信息：改变新盖放怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
end
-- 过滤函数：筛选仍处于里侧表示且与本效果有关联的怪兽
function c58621589.filter3(c,e)
	return c:IsFacedown() and c:IsRelateToEffect(e)
end
-- 效果处理：筛选出符合条件的目标怪兽并将其变为表侧攻击表示，且不触发反转效果
function c58621589.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c58621589.filter3,nil,e,tp)
	-- 将目标怪兽改变为表侧攻击表示，且不触发反转效果
	Duel.ChangePosition(g,0x1,0x1,0x1,0x1,true)
end
