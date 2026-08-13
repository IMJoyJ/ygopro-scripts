--フロッグ・バリア
-- 效果：
-- 自己场上表侧表示存在的名字带有「青蛙」的怪兽被选择作为攻击对象时才能发动。对方场上存在的攻击表示怪兽全部破坏。
function c34351849.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「青蛙」的怪兽被选择作为攻击对象时才能发动。对方场上存在的攻击表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c34351849.condition)
	e1:SetTarget(c34351849.target)
	e1:SetOperation(c34351849.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：确认当前被攻击的对象存在，且是己方场上表侧表示的名字带有「青蛙」的怪兽。
function c34351849.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被选择为攻击对象的怪兽。
	local d=Duel.GetAttackTarget()
	return d and d:IsFaceup() and d:IsControler(tp) and d:IsSetCard(0x12)
end
-- 过滤器：判断怪兽是否为攻击表示，用于筛选对方场上的攻击表示怪兽。
function c34351849.filter(c)
	return c:IsAttackPos()
end
-- 效果发动时的目标确定与操作信息设置：确认对方场上有攻击表示怪兽，并获取这些怪兽作为将被破坏的集合，同时向系统登记破坏信息。
function c34351849.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认对方场上的怪兽区域至少存在1只攻击表示的怪兽，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c34351849.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有攻击表示的怪兽集合。
	local g=Duel.GetMatchingGroup(c34351849.filter,tp,0,LOCATION_MZONE,nil)
	-- 将当前连锁的操作信息设置为破坏效果，目标为上述怪兽集合，数量为怪兽数量，供后续时点和相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：重新获取对方场上所有攻击表示的怪兽，若存在则将其全部破坏，实现“对方场上存在的攻击表示怪兽全部破坏”的处理。
function c34351849.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上当前攻击表示的怪兽集合，以确保破坏目标为处理时仍然满足条件的怪兽。
	local g=Duel.GetMatchingGroup(c34351849.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 以效果原因破坏该怪兽集合，即把对方场上的攻击表示怪兽全部送去墓地。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
