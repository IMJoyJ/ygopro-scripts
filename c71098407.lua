--もの忘れ
-- 效果：
-- 对方场上表侧攻击表示存在的怪兽的效果发动时才能发动。那个发动的效果无效，那只怪兽变成表侧守备表示。
function c71098407.initial_effect(c)
	-- 对方场上表侧攻击表示存在的怪兽的效果发动时才能发动。那个发动的效果无效，那只怪兽变成表侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c71098407.condition)
	e1:SetTarget(c71098407.target)
	e1:SetOperation(c71098407.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：对方场上的表侧攻击表示怪兽发动可被无效的效果，且该怪兽可以改变表示形式
function c71098407.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的怪兽效果，且该连锁效果可以被无效
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		and re:GetHandler():IsLocation(LOCATION_MZONE) and re:GetHandler():IsPosition(POS_FACEUP_ATTACK)
		and re:GetHandler():IsCanChangePosition()
end
-- 设置效果发动的目标：将发动效果的怪兽设为对象，并设置无效效果的操作信息
function c71098407.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将发动效果的怪兽设置为本效果的处理对象
	Duel.SetTargetCard(re:GetHandler())
	-- 设置操作信息，表明此效果包含使效果无效的分类
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果处理：使发动的效果无效，并将该怪兽变成表侧守备表示
function c71098407.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 若成功无效该效果，且该怪兽在场上与本效果有关联
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(e) then
		-- 将目标怪兽的表示形式改变为表侧守备表示
		Duel.ChangePosition(rc,POS_FACEUP_DEFENSE)
	end
end
