--細胞爆破ウイルス
-- 效果：
-- 放置有A指示物的对方怪兽的攻击宣言时才能发动。对方场上存在的攻击表示怪兽全部破坏。
function c84491298.initial_effect(c)
	-- 放置有A指示物的对方怪兽的攻击宣言时才能发动。对方场上存在的攻击表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c84491298.condition)
	e1:SetTarget(c84491298.target)
	e1:SetOperation(c84491298.activate)
	c:RegisterEffect(e1)
end
c84491298.mentioned_counter={
	[0x100e]=true,
}
-- 效果的发动条件：攻击宣言时，攻击怪兽是对方怪兽且带有A指示物
function c84491298.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动攻击的怪兽
	local a=Duel.GetAttacker()
	return a:IsControler(1-tp) and a:GetCounter(0x100e)>0
end
-- 效果的破坏过滤条件：攻击表示的怪兽
function c84491298.filter(c)
	return c:IsAttackPos()
end
-- 效果的目标选择：检查对方场上是否存在攻击表示怪兽，若存在则设置破坏对方场上全部攻击表示怪兽的操作信息
function c84491298.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在攻击表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84491298.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的全部攻击表示的怪兽
	local g=Duel.GetMatchingGroup(c84491298.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏操作信息，预计破坏获取到的全部怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果的处理：破坏对方场上的全部攻击表示怪兽
function c84491298.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的全部攻击表示的怪兽
	local g=Duel.GetMatchingGroup(c84491298.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将获取到的怪兽全部破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
