--魔封じの芳香
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，双方魔法卡若不盖放则不能发动，直到从盖放的玩家来看的下次的自己回合到来不能发动。
function c58921041.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，双方魔法卡若不盖放则不能发动，直到从盖放的玩家来看的下次的自己回合到来不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(c58921041.aclimit)
	c:RegisterEffect(e2)
	-- 直到从盖放的玩家来看的下次的自己回合到来不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SSET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c58921041.aclimset)
	c:RegisterEffect(e3)
end
-- 判断魔法卡是否满足发动条件：若不是魔法卡卡片本身的发动则允许；若魔法卡未在魔陷区盖放（如手牌直接发动）或带有未满一回合的盖放标记，则禁止发动。
function c58921041.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_SPELL) then return false end
	local c=re:GetHandler()
	return not c:IsLocation(LOCATION_SZONE) or c:GetFlagEffect(58921041)>0
end
-- 在卡片盖放时，为该卡注册一个持续到盖放玩家下次自己回合结束的标记，以此标记来限制其在规定时间内无法发动。
function c58921041.aclimset(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		local reset=tc:IsControler(tp) and RESET_OPPO_TURN or RESET_SELF_TURN
		tc:RegisterFlagEffect(58921041,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+reset,0,1)
		tc=eg:GetNext()
	end
end
