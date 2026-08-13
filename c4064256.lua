--アンデットワールド
-- 效果：
-- ①：场上的表侧表示怪兽以及墓地的怪兽变成不死族。
-- ②：双方不是不死族怪兽不能上级召唤。
function c4064256.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的表侧表示怪兽变成不死族。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(RACE_ZOMBIE)
	c:RegisterEffect(e2)
	local e2g=e2:Clone()
	e2g:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e2g:SetCondition(c4064256.gravecon)
	c:RegisterEffect(e2g)
	-- ②：双方不是不死族怪兽不能上级召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EFFECT_CANNOT_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c4064256.sumlimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e4)
	-- ①：墓地的怪兽变成不死族。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CHANGE_GRAVE_RACE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	e5:SetCondition(c4064256.gravecon)
	e5:SetValue(RACE_ZOMBIE)
	c:RegisterEffect(e5)
end
-- 作为不能召唤的限制条件：判断当前进行的召唤是否为上级召唤且召唤怪兽的种族不是不死族，若是则禁止该召唤。
function c4064256.sumlimit(e,c,tp,sumtp)
	return bit.band(sumtp,SUMMON_TYPE_ADVANCE)==SUMMON_TYPE_ADVANCE and c:GetRace()~=RACE_ZOMBIE
end
-- 墓地改变种族效果的适用条件：当效果控制者及其对方玩家均未受到“王家长眠之谷”效果影响时返回真，使墓地的怪兽变为不死族的效果生效。
function c4064256.gravecon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查效果控制者自身未受到“王家长眠之谷”效果的影响（没有王谷时条件通过）。
	return not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NECRO_VALLEY)
		-- 检查对方玩家也未受到“王家长眠之谷”效果的影响（双方墓地都未被王谷封印时条件通过）。
		and not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_NECRO_VALLEY)
end
