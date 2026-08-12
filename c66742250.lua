--アヌビスの呪い
-- 效果：
-- ①：场上的攻击表示的效果怪兽全部变成守备表示。这个回合，这个效果变成守备表示的怪兽原本守备力变成0，不能把表示形式变更。
function c66742250.initial_effect(c)
	-- ①：场上的攻击表示的效果怪兽全部变成守备表示。这个回合，这个效果变成守备表示的怪兽原本守备力变成0，不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c66742250.postg)
	e1:SetOperation(c66742250.posop)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧攻击表示、是效果怪兽且可以改变表示形式的卡
function c66742250.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsType(TYPE_EFFECT) and c:IsCanChangePosition()
end
-- 效果发动时的目标选择与操作信息设置
function c66742250.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只表侧攻击表示且可以改变表示形式的效果怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c66742250.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有表侧攻击表示且可以改变表示形式的效果怪兽
	local g=Duel.GetMatchingGroup(c66742250.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息为改变这些怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：将符合条件的怪兽变成守备表示，并使其原本守备力变成0，且不能变更表示形式
function c66742250.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有表侧攻击表示且可以改变表示形式的效果怪兽
	local g=Duel.GetMatchingGroup(c66742250.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将这些怪兽全部变成表侧守备表示
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE,0,POS_FACEUP_DEFENSE,0)
	local tc=g:GetFirst()
	while tc do
		-- 这个回合，这个效果变成守备表示的怪兽原本守备力变成0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_DEFENSE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 不能把表示形式变更。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
