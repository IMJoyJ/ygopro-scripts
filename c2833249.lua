--竜の血族
-- 效果：
-- 自己场上所有怪兽，直到结束阶段时为止全部变成龙族。
function c2833249.initial_effect(c)
	-- 自己场上所有怪兽，直到结束阶段时为止全部变成龙族。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c2833249.target)
	e1:SetOperation(c2833249.operation)
	c:RegisterEffect(e1)
end
-- 发动时的目标函数：确认自己场上存在表侧表示怪兽，以作为这张魔法卡可以发动的条件。
function c2833249.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点（chk==0）检查自己主要怪兽区是否存在至少1张表侧表示怪兽，若存在则允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理时，获取自己场上所有表侧表示怪兽，并逐一赋予‘直到结束阶段时变成龙族’的效果。
function c2833249.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上全部表侧表示怪兽的集合，作为后续变更种族处理的对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 直到结束阶段时为止全部变成龙族。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(RACE_DRAGON)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
