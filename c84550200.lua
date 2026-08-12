--ソニックジャマー
-- 效果：
-- 反转：到下一个结束阶段终了时为止，对方不能发动魔法卡。
function c84550200.initial_effect(c)
	-- 反转：到下一个结束阶段终了时为止，对方不能发动魔法卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84550200,0))  --"发动限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c84550200.operation)
	c:RegisterEffect(e1)
end
-- 反转效果的处理：创建一个影响全场的玩家效果，限制对方在下个回合结束前发动魔法卡。
function c84550200.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 到下一个结束阶段终了时为止，对方不能发动魔法卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c84550200.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 在全局环境中注册该限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动效果的条件函数：判定被发动的效果是否为魔法卡的发动。
function c84550200.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
