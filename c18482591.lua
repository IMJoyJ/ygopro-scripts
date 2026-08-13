--氷結界の破術師
-- 效果：
-- ①：只要自己场上有其他的「冰结界」怪兽存在，双方魔法卡若不盖放则不能发动，直到从盖放的玩家来看的下次的自己回合到来不能发动。
function c18482591.initial_effect(c)
	-- ①：只要自己场上有其他的「冰结界」怪兽存在，双方魔法卡若不盖放则不能发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetCondition(c18482591.con)
	e2:SetValue(c18482591.aclimit)
	c:RegisterEffect(e2)
	-- 直到从盖放的玩家来看的下次的自己回合到来不能发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SSET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c18482591.con)
	e3:SetOperation(c18482591.aclimset)
	c:RegisterEffect(e3)
end
-- 筛选表侧表示且属于「冰结界」字段的怪兽。
function c18482591.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 效果发动/适用的条件：自己场上存在1只以上其他表侧表示的「冰结界」怪兽。
function c18482591.con(e)
	-- 存在性判断：以本卡控制者视角检查其怪兽区是否存在1只以上满足filter且不是本卡的「冰结界」怪兽。
	return Duel.IsExistingMatchingCard(c18482591.filter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 禁止发动判定：若试图发动的不是魔法卡的发动则放行；若魔法卡不在魔陷区（即从手卡直接发动）则禁止；若在魔陷区但带有18482591标记（刚盖放、尚未到下个自己回合）也禁止。
function c18482591.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_SPELL) then return false end
	local c=re:GetHandler()
	return not c:IsLocation(LOCATION_SZONE) or c:GetFlagEffect(18482591)>0
end
-- 盖放标记处理：当魔法·陷阱卡被盖放时，为该卡注册标记，使其在盖放玩家的下个自己回合到来前不能发动；重置时机根据盖放卡控制者选择对方回合/自己回合的结束阶段，配合标准离场重置清除标记。
function c18482591.aclimset(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		local reset=tc:IsControler(tp) and RESET_OPPO_TURN or RESET_SELF_TURN
		tc:RegisterFlagEffect(18482591,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+reset,0,1)
		tc=eg:GetNext()
	end
end
