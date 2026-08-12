--焔紫竜ピュラリス
-- 效果：
-- 调整＋调整以外的怪兽1只
-- ①：这张卡从场上送去墓地的场合发动。对方场上的全部怪兽的攻击力下降500。
function c37038993.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
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
-- 效果发动条件：确认此卡是从场上被送去墓地
function c37038993.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果处理：检索对方场上所有表侧表示的怪兽并将其攻击力下降500
function c37038993.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为每张检索到的怪兽设置攻击力下降500的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
