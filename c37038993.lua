--焔紫竜ピュラリス
-- 效果：
-- 调整＋调整以外的怪兽1只
-- ①：这张卡从场上送去墓地的场合发动。对方场上的全部怪兽的攻击力下降500。
function c37038993.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽＋1只调整以外的怪兽（同调素材合计2只）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- ①：这张卡从场上送去墓地的场合发动。对方场上的全部怪兽的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37038993,0))  --"攻击下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c37038993.atkcon)
	e1:SetOperation(c37038993.atkop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：此卡在送去墓地前位于场上（从场上送去墓地才满足发动条件，从手卡/卡组等其他区域送去墓地则不发动）。
function c37038993.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果处理：不取对象地获取对方场上的全部表侧表示怪兽，逐只赋予攻击力下降500的效果，并在卡片离场等标准重置时机到来时使该效果失效。
function c37038993.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 以我方视角获取对方怪兽区域的全部表侧表示怪兽，作为后续处理对象（不取对象）。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部怪兽的攻击力下降500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
