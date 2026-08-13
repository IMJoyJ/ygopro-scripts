--閃光のバリア －シャイニング・フォース－
-- 效果：
-- 对方场上攻击表示怪兽有3只以上存在的场合，对方的攻击宣言时才能发动。对方场上的攻击表示怪兽全部破坏。
function c21481146.initial_effect(c)
	-- 对方场上攻击表示怪兽有3只以上存在的场合，对方的攻击宣言时才能发动。对方场上的攻击表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c21481146.condition)
	e1:SetTarget(c21481146.target)
	e1:SetOperation(c21481146.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件的判定函数：仅在对方回合且对方场上有3只以上表侧攻击表示怪兽时允许发动，对应效果原文中“对方场上攻击表示怪兽有3只以上存在的场合，对方的攻击宣言时才能发动”。
function c21481146.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前玩家不是回合玩家（即对方回合），并且以我方视角查看对方场上存在至少3只表侧攻击表示怪兽。
	return tp~=Duel.GetTurnPlayer() and Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_MZONE,3,nil,POS_FACEUP_ATTACK)
end
-- 筛选函数：判断怪兽是否为攻击表示。
function c21481146.filter(c)
	return c:IsAttackPos()
end
-- 效果发动时的目标处理函数：进行发动合法性检查，并预选对方场上全部攻击表示怪兽，设置本次效果将破坏这些怪兽的操作信息。
function c21481146.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查（chk==0）时，确认对方场上存在至少1只攻击表示怪兽，满足发动前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c21481146.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方场上当前存在的所有攻击表示怪兽的集合。
	local g=Duel.GetMatchingGroup(c21481146.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：将集合g中的全部怪兽作为破坏对象，数量为g中的卡数，类别为破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时的操作函数：在处理时重新获取对方场上全部攻击表示怪兽，并将其全部破坏，对应效果原文“对方场上的攻击表示怪兽全部破坏”。
function c21481146.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取对方场上所有攻击表示怪兽的集合，以保证处理的是当前实际存在的怪兽。
	local g=Duel.GetMatchingGroup(c21481146.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 以效果（REASON_EFFECT）为原因将集合g中的怪兽全部破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
