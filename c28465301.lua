--ワーム・オペラ
-- 效果：
-- 反转：名字带有「异虫」的爬虫类族怪兽以外的场上表侧表示存在的全部怪兽的攻击力下降500。
function c28465301.initial_effect(c)
	-- 反转：名字带有「异虫」的爬虫类族怪兽以外的场上表侧表示存在的全部怪兽的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FLIP+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetOperation(c28465301.valop)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡牌为表侧表示，且不是名字带有「异虫」的爬虫类族怪兽，即满足被下降攻击力条件的怪兽。
function c28465301.filter(c)
	return c:IsFaceup() and not (c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE))
end
-- 效果处理：检索场上所有满足条件的表侧表示怪兽，并逐一使其攻击力下降500。
function c28465301.valop(e,tp,eg,ep,ev,re,r,rp)
	-- 从双方主要怪兽区获取全部满足过滤器条件的表侧表示怪兽（不取对象，在效果处理时确定）。
	local g=Duel.GetMatchingGroup(c28465301.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力下降500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
