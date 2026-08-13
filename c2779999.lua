--棘の壁
-- 效果：
-- 自己场上表侧表示存在的植物族怪兽被选择作为攻击对象时才能发动。对方场上存在的攻击表示怪兽全部破坏。
function c2779999.initial_effect(c)
	-- 自己场上表侧表示存在的植物族怪兽被选择作为攻击对象时才能发动。对方场上存在的攻击表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c2779999.condition)
	e1:SetTarget(c2779999.target)
	e1:SetOperation(c2779999.activate)
	c:RegisterEffect(e1)
end
-- 判定被选择为攻击对象的怪兽是否为自己场上表侧表示的植物族怪兽，以此作为发动条件。
function c2779999.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsFaceup() and tc:IsRace(RACE_PLANT)
end
-- 过滤条件：怪兽为攻击表示，用于选择对方场上攻击表示的怪兽。
function c2779999.filter(c)
	return c:IsAttackPos()
end
-- 发动时的目标处理：检查对方场上是否存在攻击表示怪兽，并获取全部攻击表示怪兽作为本卡将破坏的对象，登记破坏操作信息。
function c2779999.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段，确认对方场上有至少1只攻击表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c2779999.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 在发动时获取对方场上当前所有攻击表示怪兽的集合，用于设置破坏操作信息。
	local g=Duel.GetMatchingGroup(c2779999.filter,tp,0,LOCATION_MZONE,nil)
	-- 将上述攻击表示怪兽集合及其数量登记到当前连锁的破坏操作信息中，使破坏效果能被正确检测和对应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，重新获取对方场上所有攻击表示怪兽；若存在，则将其全部破坏。
function c2779999.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上当前所有攻击表示怪兽，确保实际破坏的是处理时存在的攻击表示怪兽。
	local g=Duel.GetMatchingGroup(c2779999.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 以卡牌效果为原因破坏对方场上全部攻击表示怪兽，将其送入墓地。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
