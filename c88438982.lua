--ワーム・ディミクレス
-- 效果：
-- 反转：只要这张卡在场上表侧表示存在，这张卡的攻击力·守备力上升300。
function c88438982.initial_effect(c)
	-- 反转：只要这张卡在场上表侧表示存在，这张卡的攻击力·守备力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FLIP+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetOperation(c88438982.adop)
	c:RegisterEffect(e1)
end
-- 反转效果的处理：检查自身是否表侧表示且与效果有关联，若是则为其注册攻击力和守备力上升300的效果。
function c88438982.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 只要这张卡在场上表侧表示存在，这张卡的攻击力...上升300
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
