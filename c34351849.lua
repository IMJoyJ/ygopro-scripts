--フロッグ・バリア
-- 效果：
-- 自己场上表侧表示存在的名字带有「青蛙」的怪兽被选择作为攻击对象时才能发动。对方场上存在的攻击表示怪兽全部破坏。
function c34351849.initial_effect(c)
	-- 效果定义：发动条件为对方怪兽攻击自己场上表侧表示存在的名字带有「青蛙」的怪兽时，效果类型为发动效果，触发事件为被选为攻击对象，效果分类为破坏，效果条件为c34351849.condition，效果目标为c34351849.target，效果处理为c34351849.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c34351849.condition)
	e1:SetTarget(c34351849.target)
	e1:SetOperation(c34351849.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：判断攻击对象是否为己方场上表侧表示存在的名字带有「青蛙」的怪兽
function c34351849.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击对象
	local d=Duel.GetAttackTarget()
	return d and d:IsFaceup() and d:IsControler(tp) and d:IsSetCard(0x12)
end
-- 过滤函数：判断怪兽是否为攻击表示
function c34351849.filter(c)
	return c:IsAttackPos()
end
-- 效果目标：检查对方场上是否存在攻击表示怪兽，若存在则设置破坏效果的目标为这些怪兽
function c34351849.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在攻击表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c34351849.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有攻击表示怪兽组成的组
	local g=Duel.GetMatchingGroup(c34351849.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：将对方场上攻击表示怪兽设为破坏效果的目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：检索对方场上所有攻击表示怪兽并将其破坏
function c34351849.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有攻击表示怪兽组成的组
	local g=Duel.GetMatchingGroup(c34351849.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将目标怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
