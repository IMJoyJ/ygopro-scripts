--閃光のバリア －シャイニング・フォース－
-- 效果：
-- 对方场上攻击表示怪兽有3只以上存在的场合，对方的攻击宣言时才能发动。对方场上的攻击表示怪兽全部破坏。
function c21481146.initial_effect(c)
	-- 效果原文内容：对方场上攻击表示怪兽有3只以上存在的场合，对方的攻击宣言时才能发动。对方场上的攻击表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c21481146.condition)
	e1:SetTarget(c21481146.target)
	e1:SetOperation(c21481146.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查是否满足发动条件，即对方回合且对方场上存在至少3只攻击表示怪兽。
function c21481146.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断当前回合玩家是否为对方，以及对方场上是否存在至少3只攻击表示怪兽。
	return tp~=Duel.GetTurnPlayer() and Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_MZONE,3,nil,POS_FACEUP_ATTACK)
end
-- 效果作用：过滤函数，用于判断卡是否为攻击表示。
function c21481146.filter(c)
	return c:IsAttackPos()
end
-- 效果作用：设置连锁处理的目标，确定要破坏的攻击表示怪兽。
function c21481146.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：在确认阶段检查是否满足发动条件，即对方场上存在至少1只攻击表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c21481146.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 效果作用：获取对方场上所有攻击表示怪兽组成的组。
	local g=Duel.GetMatchingGroup(c21481146.filter,tp,0,LOCATION_MZONE,nil)
	-- 效果作用：设置操作信息，指定将要破坏的怪兽组及数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用：执行效果，将符合条件的怪兽全部破坏。
function c21481146.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取对方场上所有攻击表示怪兽组成的组。
	local g=Duel.GetMatchingGroup(c21481146.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 效果作用：将指定怪兽组以效果原因进行破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
