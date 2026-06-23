--天狗のうちわ
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，2星以下的怪兽在反转召唤成功时破坏。这个时候，那只怪兽不能把场上发动的效果发动。
function c4149689.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，2星以下的怪兽在反转召唤成功时破坏。这个时候，那只怪兽不能把场上发动的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(c4149689.aclimit)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，2星以下的怪兽在反转召唤成功时破坏。这个时候，那只怪兽不能把场上发动的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4149689,0))  --"破坏"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c4149689.desop)
	c:RegisterEffect(e3)
end
-- 当怪兽在场上发动效果时，若该怪兽为等级2以下且在反转召唤成功时，阻止其发动效果。
function c4149689.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE and rc:GetFlagEffect(4149689)~=0
end
-- 当怪兽反转召唤成功时，若该怪兽等级为2以下，则将其破坏并标记该怪兽已触发效果。
function c4149689.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsLevelBelow(2) then
		-- 将目标怪兽因效果而破坏
		Duel.Destroy(tc,REASON_EFFECT)
		tc:RegisterFlagEffect(4149689,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
