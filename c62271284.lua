--ジャスティブレイク
-- 效果：
-- 自己场上的通常怪兽为攻击对象的对方怪兽的攻击宣言时才能发动。表侧攻击表示存在的通常怪兽以外的场上的怪兽全部破坏。
function c62271284.initial_effect(c)
	-- 自己场上的通常怪兽为攻击对象的对方怪兽的攻击宣言时才能发动。表侧攻击表示存在的通常怪兽以外的场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c62271284.condition)
	e1:SetTarget(c62271284.target)
	e1:SetOperation(c62271284.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件：必须在对方回合，且攻击对象是自己场上的表侧表示通常怪兽
function c62271284.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标（被攻击的怪兽）
	local at=Duel.GetAttackTarget()
	-- 判断是否为对方回合的攻击宣言，且攻击目标存在、呈表侧表示、是通常怪兽
	return tp~=Duel.GetTurnPlayer() and at and at:IsFaceup() and at:IsType(TYPE_NORMAL)
end
-- 过滤条件：非“表侧表示且是通常怪兽且呈攻击表示”的怪兽（即需要被破坏的怪兽）
function c62271284.filter(c)
	return not (c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsAttackPos())
end
-- 定义效果发动的目标选择与操作信息
function c62271284.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0），检查场上是否存在至少1只符合破坏条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c62271284.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有符合破坏条件的怪兽
	local g=Duel.GetMatchingGroup(c62271284.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息，表示此效果将破坏这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义效果处理：获取并破坏所有符合条件的怪兽
function c62271284.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取场上所有符合破坏条件的怪兽
	local g=Duel.GetMatchingGroup(c62271284.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将这些怪兽全部因效果破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
