--遅すぎたオーク
-- 效果：
-- 这张卡在召唤的回合不能攻击。
function c64892035.initial_effect(c)
	-- 这张卡在召唤的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c64892035.atklimit)
	c:RegisterEffect(e1)
end
-- 通常召唤成功时，给自身施加回合结束前不能攻击的限制
function c64892035.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
