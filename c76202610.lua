--ダークロン
-- 效果：
-- 这张卡召唤成功时才能发动。自己场上表侧表示存在的怪兽直到结束阶段时等级上升1星并变成暗属性。
function c76202610.initial_effect(c)
	-- 这张卡召唤成功时才能发动。自己场上表侧表示存在的怪兽直到结束阶段时等级上升1星并变成暗属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76202610,0))  --"等级属性变化"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c76202610.operation)
	c:RegisterEffect(e1)
end
-- 循环处理自己场上所有表侧表示的怪兽，使其等级上升1星并变成暗属性，该效果持续到结束阶段。
function c76202610.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上表侧表示存在的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 直到结束阶段时等级上升1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 并变成暗属性
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(ATTRIBUTE_DARK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
