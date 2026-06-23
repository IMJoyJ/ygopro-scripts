--コアキメイルの障壁
-- 效果：
-- 自己墓地有「核成兽的钢核」2张以上存在的场合，对方怪兽的攻击宣言时才能发动。对方场上表侧攻击表示存在的怪兽全部破坏。
function c12216615.initial_effect(c)
	-- 为卡片注册“核成兽的钢核”作为效果文本中提及的特定卡片
	aux.AddCodeList(c,36623431)
	-- 自己墓地有「核成兽的钢核」2张以上存在的场合，对方怪兽的攻击宣言时才能发动。对方场上表侧攻击表示存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c12216615.condition)
	e1:SetTarget(c12216615.target)
	e1:SetOperation(c12216615.activate)
	c:RegisterEffect(e1)
end
-- 判断效果发动条件的函数
function c12216615.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合且自己墓地有2张以上「核成兽的钢核」
	return tp~=Duel.GetTurnPlayer() and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,2,nil,36623431)
end
-- 用于过滤怪兽位置的函数
function c12216615.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
-- 设置效果目标的函数
function c12216615.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即对方场上存在表侧攻击表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c12216615.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧攻击表示的怪兽
	local g=Duel.GetMatchingGroup(c12216615.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果发动时执行破坏操作的函数
function c12216615.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取对方场上所有表侧攻击表示的怪兽
	local g=Duel.GetMatchingGroup(c12216615.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将符合条件的怪兽全部破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
