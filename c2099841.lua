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
-- 效果发动的目标条件处理：确认场上是否存在表侧表示怪兽，以保证效果能够处理。
function c2099841.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段（chk==0），检测双方场上主要怪兽区是否存在至少1只表侧表示怪兽，以此作为效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果处理阶段：先收集场上所有表侧表示怪兽，并统计场上怪兽总数量，然后为每只表侧怪兽赋予攻击力上升（数量×100）直到回合结束的效果。
function c2099841.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上主要怪兽区所有表侧表示的怪兽，构成怪兽组g，用于后续逐个赋予攻击力变化。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 获取场上全部怪兽的总数量（包含里侧表示怪兽），作为攻击力上升的计算基数。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)
	local tc=g:GetFirst()
	while tc do
		-- 为当前表侧怪兽赋予“攻击力直到回合结束时上升场上的怪兽数量×100”的效果。对应原文：①：场上的全部怪兽的攻击力直到回合结束时上升场上的怪兽数量×100。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
