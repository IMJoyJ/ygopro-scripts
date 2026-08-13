--聖なるバリア －ミラーフォース－
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。对方场上的攻击表示怪兽全部破坏。
function c44095762.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。对方场上的攻击表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c44095762.condition)
	e1:SetTarget(c44095762.target)
	e1:SetOperation(c44095762.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：必须是对方的回合（即当前回合玩家不是效果发动者）才能发动，对应“对方怪兽的攻击宣言时”。
function c44095762.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是效果发动者，即满足“对方回合”的条件。
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤函数：筛选出场上攻击表示的怪兽。
function c44095762.filter(c)
	return c:IsAttackPos()
end
-- 效果发动时的目标筛选与操作信息登记：合法时收集对方场上全部攻击表示怪兽并登记为破坏对象。
function c44095762.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动合法性检查（chk==0），则确认对方场上是否存在至少1只攻击表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c44095762.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有攻击表示的怪兽作为将要破坏的群体。
	local g=Duel.GetMatchingGroup(c44095762.filter,tp,0,LOCATION_MZONE,nil)
	-- 向游戏系统登记本次效果将破坏这些怪兽的信息（用于连锁判定、星尘龙等响应）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：破坏对方场上全部攻击表示怪兽。
function c44095762.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上当前存在的全部攻击表示怪兽。
	local g=Duel.GetMatchingGroup(c44095762.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将这些怪兽以效果原因破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
