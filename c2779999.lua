--棘の壁
-- 效果：
-- 自己场上表侧表示存在的植物族怪兽被选择作为攻击对象时才能发动。对方场上存在的攻击表示怪兽全部破坏。
function c2779999.initial_effect(c)
	-- 效果原文内容：自己场上表侧表示存在的植物族怪兽被选择作为攻击对象时才能发动。对方场上存在的攻击表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c2779999.condition)
	e1:SetTarget(c2779999.target)
	e1:SetOperation(c2779999.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查被选为攻击对象的怪兽是否为自己的植物族表侧表示怪兽
function c2779999.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsFaceup() and tc:IsRace(RACE_PLANT)
end
-- 规则层面作用：过滤函数，用于判断怪兽是否处于攻击表示
function c2779999.filter(c)
	return c:IsAttackPos()
end
-- 规则层面作用：设置连锁处理的目标为对方场上所有攻击表示的怪兽
function c2779999.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断对方场上是否存在攻击表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c2779999.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 规则层面作用：获取对方场上所有攻击表示的怪兽组成组
	local g=Duel.GetMatchingGroup(c2779999.filter,tp,0,LOCATION_MZONE,nil)
	-- 规则层面作用：设置连锁操作信息，指定将要破坏的怪兽组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面作用：发动效果，破坏对方场上所有攻击表示的怪兽
function c2779999.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取对方场上所有攻击表示的怪兽组成组
	local g=Duel.GetMatchingGroup(c2779999.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 规则层面作用：将指定怪兽组以效果原因进行破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
