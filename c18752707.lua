--マジカル・スター・イリュージョン
-- 效果：
-- ①：自己场上的怪兽数量是对方场上的怪兽数量以下的场合才能发动。自己以及对方场上的怪兽的攻击力直到回合结束时上升那怪兽的控制者场上的怪兽的等级合计×100。
function c18752707.initial_effect(c)
	-- 效果发动条件设置为自由时点且需要满足条件、有目标、有发动效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c18752707.condition)
	e1:SetTarget(c18752707.target)
	e1:SetOperation(c18752707.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：自己场上的怪兽数量是对方场上的怪兽数量以下的场合才能发动
function c18752707.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上的怪兽数量小于等于对方场上的怪兽数量
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 效果发动目标：检查自己场上是否存在表侧表示的怪兽
function c18752707.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1张表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果发动时的处理：检索满足条件的怪兽组并为它们设置攻击力提升效果
function c18752707.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索自己场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	-- 计算自己场上所有表侧表示怪兽的等级总和并乘以100作为攻击力提升值
	local val1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetSum(Card.GetLevel)*100
	-- 计算对方场上所有表侧表示怪兽的等级总和并乘以100作为攻击力提升值
	local val2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetSum(Card.GetLevel)*100
	while tc do
		-- 为每张符合条件的怪兽设置攻击力提升效果，提升值根据控制者不同而不同
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		if tc:IsControler(tp) then
			e1:SetValue(val1)
		else
			e1:SetValue(val2)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
