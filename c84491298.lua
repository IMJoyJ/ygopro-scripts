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
-- 卡片发动条件：攻击宣言的怪兽为对方控制且带有A指示物
function c84491298.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击宣言怪兽
	local a=Duel.GetAttacker()
	return a:IsControler(1-tp) and a:GetCounter(0x100e)>0
end
-- 破坏目标过滤条件：攻击表示的怪兽
function c84491298.filter(c)
	return c:IsAttackPos()
end
-- 卡片发动准备：检查对方场上是否存在攻击表示怪兽，并设置破坏操作信息
function c84491298.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：对方场上是否存在至少1只攻击表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84491298.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的攻击表示怪兽
	local g=Duel.GetMatchingGroup(c84491298.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：破坏对方场上全部攻击表示怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 卡片效果处理：将对方场上的攻击表示怪兽全部破坏
function c84491298.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上当前所有的攻击表示怪兽
	local g=Duel.GetMatchingGroup(c84491298.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将获取到的所有攻击表示怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
