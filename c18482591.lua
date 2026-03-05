--氷結界の破術師
-- 效果：
-- ①：只要自己场上有其他的「冰结界」怪兽存在，双方魔法卡若不盖放则不能发动，直到从盖放的玩家来看的下次的自己回合到来不能发动。
function c18482591.initial_effect(c)
	-- 效果原文：①：只要自己场上有其他的「冰结界」怪兽存在，双方魔法卡若不盖放则不能发动，直到从盖放的玩家来看的下次的自己回合到来不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetCondition(c18482591.con)
	e2:SetValue(c18482591.aclimit)
	c:RegisterEffect(e2)
	-- 效果原文：①：只要自己场上有其他的「冰结界」怪兽存在，双方魔法卡若不盖放则不能发动，直到从盖放的玩家来看的下次的自己回合到来不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SSET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c18482591.con)
	e3:SetOperation(c18482591.aclimset)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于检查场上是否存在表侧表示的「冰结界」怪兽
function c18482591.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 条件函数，判断是否满足发动效果的条件（场上存在其他「冰结界」怪兽）
function c18482591.con(e)
	-- 检查以效果持有者为玩家，在自己场上是否存在至少1张满足filter条件的怪兽（不包括自身）
	return Duel.IsExistingMatchingCard(c18482591.filter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 限制发动函数，判断魔法卡是否能发动（若不是魔法卡或未盖放则不能发动）
function c18482591.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_SPELL) then return false end
	local c=re:GetHandler()
	return not c:IsLocation(LOCATION_SZONE) or c:GetFlagEffect(18482591)>0
end
-- 设置标志效果函数，为盖放的魔法卡设置标志，使其在下次自己回合前不能发动
function c18482591.aclimset(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		local reset=tc:IsControler(tp) and RESET_OPPO_TURN or RESET_SELF_TURN
		tc:RegisterFlagEffect(18482591,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+reset,0,1)
		tc=eg:GetNext()
	end
end
