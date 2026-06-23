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
-- 定义发动条件检查函数：确认自己场上存在表侧表示的怪兽可作为效果对象
function c2833249.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
-- 定义效果处理函数：获取场上所有表侧表示怪兽，并为每只怪兽附加龙族变化效果直至结束阶段
function c2833249.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 全部变成龙族，直到结束阶段时为止
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(RACE_DRAGON)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
