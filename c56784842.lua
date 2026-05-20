--エンジェルO7
-- 效果：
-- 这张卡的祭品召唤成功时，这张卡得到以下效果。
-- ●只要这张卡在场上表侧表示存在，效果怪兽不能把效果发动。
function c56784842.initial_effect(c)
	-- 这张卡的祭品召唤成功时，这张卡得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c56784842.regop)
	c:RegisterEffect(e1)
end
-- 在召唤成功时，若判定为上级召唤，则为自身注册在场上表侧表示存在时限制双方玩家发动效果的永续效果。
function c56784842.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_ADVANCE) then return end
	-- ●只要这张卡在场上表侧表示存在，效果怪兽不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c56784842.aclimit)
	c:RegisterEffect(e1)
end
-- 限制发动的效果类型为怪兽的效果。
function c56784842.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
