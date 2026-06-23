--スローライフ
-- 效果：
-- 自己场上没有怪兽存在的场合，自己主要阶段1开始时才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，以下效果适用。
-- ●把怪兽通常召唤的玩家在那个回合不能把怪兽特殊召唤。
-- ●把怪兽特殊召唤的玩家在那个回合不能把怪兽通常召唤。
function c31980955.initial_effect(c)
	-- ①：只要这张卡在魔法与陷阱区域存在，以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c31980955.condition)
	c:RegisterEffect(e1)
	-- ●把怪兽通常召唤的玩家在那个回合不能把怪兽特殊召唤。
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
-- 自己主要阶段1开始时才能把这张卡发动。
function c31980955.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1且未进行过阶段操作
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
		-- 自己场上没有怪兽存在
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 判断目标玩家在当前回合是否进行过特殊召唤
function c31980955.sumlimit1(e,c,sump,sumtype,sumpos,targetp,se)
	-- 如果目标玩家在当前回合进行过特殊召唤则返回true
	return Duel.GetActivityCount(sump,ACTIVITY_SPSUMMON)>0
end
-- ●把怪兽特殊召唤的玩家在那个回合不能把怪兽通常召唤。
function c31980955.sumlimit2(e,c,sump,sumtype,sumpos,targetp,se)
	-- 如果目标玩家在当前回合进行过通常召唤则返回true
	return Duel.GetActivityCount(sump,ACTIVITY_NORMALSUMMON)>0
end
