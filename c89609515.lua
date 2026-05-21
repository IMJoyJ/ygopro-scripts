--ラヴァル・フロギス
-- 效果：
-- 这张卡被送去墓地时，自己场上表侧表示存在的全部名字带有「熔岩」的怪兽的攻击力上升300。
function c89609515.initial_effect(c)
	-- 这张卡被送去墓地时，自己场上表侧表示存在的全部名字带有「熔岩」的怪兽的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89609515,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c89609515.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示且卡名含有「熔岩」的怪兽
function c89609515.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x39)
end
-- 效果处理：获取自己场上所有符合条件的「熔岩」怪兽，并循环为其注册攻击力上升的效果
function c89609515.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「熔岩」怪兽
	local g=Duel.GetMatchingGroup(c89609515.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力上升300
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
