--スマイル・ワールド
-- 效果：
-- ①：场上的全部怪兽的攻击力直到回合结束时上升场上的怪兽数量×100。
function c2099841.initial_effect(c)
	-- ①：场上的全部怪兽的攻击力直到回合结束时上升场上的怪兽数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c2099841.target)
	e1:SetOperation(c2099841.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的场上正面表示怪兽组
function c2099841.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索满足条件的场上正面表示怪兽组
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 获取场上正面表示怪兽数量并为每只怪兽添加攻击力上升效果
function c2099841.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上正面表示怪兽数量
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 获取场上正面表示怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)
	local tc=g:GetFirst()
	while tc do
		-- ①：场上的全部怪兽的攻击力直到回合结束时上升场上的怪兽数量×100。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
