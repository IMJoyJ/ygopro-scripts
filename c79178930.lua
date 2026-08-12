--時限カラクリ爆弾
-- 效果：
-- 表侧守备表示存在的名字带有「机巧」的怪兽被选择作为攻击对象时才能发动。对方场上表侧表示存在的怪兽全部破坏。
function c79178930.initial_effect(c)
	-- 表侧守备表示存在的名字带有「机巧」的怪兽被选择作为攻击对象时才能发动。对方场上表侧表示存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c79178930.condition)
	e1:SetTarget(c79178930.target)
	e1:SetOperation(c79178930.activate)
	c:RegisterEffect(e1)
end
-- 检查被选择作为攻击对象的怪兽是否为表侧守备表示的「机巧」怪兽
function c79178930.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsFaceup() and tc:IsDefensePos() and tc:IsSetCard(0x11)
end
-- 过滤表侧表示的卡片
function c79178930.filter(c)
	return c:IsFaceup()
end
-- 发动时的效果目标检测与操作信息设置
function c79178930.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c79178930.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c79178930.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏对方场上所有表侧表示怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理的执行函数，获取并破坏对方场上所有表侧表示的怪兽
function c79178930.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c79178930.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 因效果破坏这些怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
