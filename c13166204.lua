--ガガガラッシュ
-- 效果：
-- 自己场上的名字带有「我我我」的怪兽成为对方怪兽的效果的对象时才能发动。那只对方怪兽的效果无效并破坏。那之后，给与对方基本分破坏的怪兽的攻击力和守备力之内较高方数值的伤害。
function c13166204.initial_effect(c)
	-- 自己场上的名字带有「我我我」的怪兽成为对方怪兽的效果的对象时才能发动。那只对方怪兽的效果无效并破坏。那之后，给与对方基本分破坏的怪兽的攻击力和守备力之内较高方数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetCondition(c13166204.condition)
	e1:SetTarget(c13166204.target)
	e1:SetOperation(c13166204.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：表侧表示、由我方控制、位于主要怪兽区域、卡名带有「我我我」字段（0x54）的怪兽。
function c13166204.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x54)
end
-- 发动条件：对方怪兽的效果将我方场上的「我我我」怪兽选为对象（eg中存在满足筛选的卡），且该连锁可以被无效。
function c13166204.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定条件依次为：效果由对方玩家发动（rp==1-tp）；发动效果为怪兽效果；成为对象的怪兽组中包含我方场上符合条件的「我我我」怪兽；当前连锁效果能够被无效。
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and eg:IsExists(c13166204.filter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 发动时处理：声明本卡将无效对方效果并破坏那只怪兽，若满足追加条件则同时设置给对方造成伤害的操作信息。
function c13166204.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将发动时成为对象的怪兽组（eg）标记为无效对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：将效果发动者（re:GetHandler()）标记为破坏对象，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,re:GetHandler(),1,0,0)
		-- 设置操作信息：声明将给对方造成伤害，伤害对象不确定（不取对象），目标玩家为对方，数量参数为0。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end
-- 效果处理：无效对方怪兽效果，破坏该怪兽；若破坏成功，则取该怪兽攻击力与守备力较高者给对方造成伤害。
function c13166204.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判定并执行：先无效对方连锁效果，再确认效果发动者仍与该效果关联且可被效果破坏，然后将其破坏并判断破坏成功（返回值非0）。
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(re:GetHandler(),REASON_EFFECT)~=0 then
		local a=re:GetHandler():GetAttack()
		local b=re:GetHandler():GetDefense()
		if b>a then a=b end
		if a>0 then
			-- 中断当前效果处理，使后续的伤害处理与前面的无效/破坏视为不同步，会造成错时点。
			Duel.BreakEffect()
			-- 给与对方（1-tp）玩家a点伤害，伤害原因为效果。
			Duel.Damage(1-tp,a,REASON_EFFECT)
		end
	end
end
