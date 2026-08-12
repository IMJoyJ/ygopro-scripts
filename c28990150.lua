--フォトン・ケルベロス
-- 效果：
-- 这张卡召唤成功的回合，只要这张卡在场上表侧表示存在双方不能把陷阱卡发动。
function c28990150.initial_effect(c)
	-- 这张卡召唤成功的回合，只要这张卡在场上表侧表示存在双方不能把陷阱卡发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c28990150.atkop)
	c:RegisterEffect(e3)
end
-- 在怪兽通常召唤成功时触发，创建一个永续效果来禁止双方发动陷阱卡。
function c28990150.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 在怪兽通常召唤成功时触发，创建一个永续效果来禁止双方发动陷阱卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c28990150.aclimit)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 判断效果是否为发动陷阱卡的效果，若是则禁止该发动。
function c28990150.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsType(TYPE_TRAP)
end
