--スローライフ
-- 效果：
-- 自己场上没有怪兽存在的场合，自己主要阶段1开始时才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，以下效果适用。
-- ●把怪兽通常召唤的玩家在那个回合不能把怪兽特殊召唤。
-- ●把怪兽特殊召唤的玩家在那个回合不能把怪兽通常召唤。
function c31980955.initial_effect(c)
	-- 自己场上没有怪兽存在的场合，自己主要阶段1开始时才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c31980955.condition)
	c:RegisterEffect(e1)
	-- ●把怪兽特殊召唤的玩家在那个回合不能把怪兽通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c31980955.sumlimit1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetTarget(c31980955.sumlimit2)
	c:RegisterEffect(e4)
end
-- 判断发动条件：自己场上没有怪兽，且处于自己主要阶段1开始时（尚未进行任何操作）才能发动。
function c31980955.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1且处于阶段开始时（尚未进行过任何操作）。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
		-- 判断自己场上（主要怪兽区域）没有怪兽存在。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 该判定用于禁止通常召唤/覆盖：若进行通常召唤的玩家本回合已经进行过特殊召唤，则不能进行通常召唤（或覆盖）。
function c31980955.sumlimit1(e,c,sump,sumtype,sumpos,targetp,se)
	-- 检查该玩家本回合是否进行过特殊召唤（特殊召唤次数>0）。
	return Duel.GetActivityCount(sump,ACTIVITY_SPSUMMON)>0
end
-- 该判定用于禁止特殊召唤：若进行特殊召唤的玩家本回合已经进行过通常召唤，则不能进行特殊召唤。
function c31980955.sumlimit2(e,c,sump,sumtype,sumpos,targetp,se)
	-- 检查该玩家本回合是否进行过通常召唤（通常召唤次数>0）。
	return Duel.GetActivityCount(sump,ACTIVITY_NORMALSUMMON)>0
end
