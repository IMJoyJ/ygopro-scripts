--マジカル・スター・イリュージョン
-- 效果：
-- ①：自己场上的怪兽数量是对方场上的怪兽数量以下的场合才能发动。自己以及对方场上的怪兽的攻击力直到回合结束时上升那怪兽的控制者场上的怪兽的等级合计×100。
function c18752707.initial_effect(c)
	-- ①：自己场上的怪兽数量是对方场上的怪兽数量以下的场合才能发动。自己以及对方场上的怪兽的攻击力直到回合结束时上升那怪兽的控制者场上的怪兽的等级合计×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c18752707.condition)
	e1:SetTarget(c18752707.target)
	e1:SetOperation(c18752707.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件：己方场上怪兽数量不超过对方场上怪兽数量时才能发动。
function c18752707.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上主要怪兽区的怪兽数量是否不大于对方场上主要怪兽区的怪兽数量。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 效果发动时的目标检查函数，此处仅验证场上是否存在表侧表示怪兽，以决定是否满足发动条件。
function c18752707.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认双方场上合计存在至少1只表侧表示怪兽（若不存在则不能发动）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果处理部分：收集场上所有表侧表示怪兽，分别计算双方各自场上表侧表示怪兽的等级合计×100，然后为每只表侧怪兽赋予对应的攻击力上升效果，持续到回合结束。
function c18752707.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	-- 计算己方场上所有表侧表示怪兽的等级合计×100，作为己方控制怪兽的攻击力上升数值。
	local val1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetSum(Card.GetLevel)*100
	-- 计算对方场上所有表侧表示怪兽的等级合计×100，作为对方控制怪兽的攻击力上升数值。
	local val2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetSum(Card.GetLevel)*100
	while tc do
		-- 自己以及对方场上的怪兽的攻击力直到回合结束时上升那怪兽的控制者场上的怪兽的等级合计×100。
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
