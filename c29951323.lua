--放電ムスタンガン
-- 效果：
-- 这张卡不能通常召唤，在自己没有进行特殊召唤的自己主要阶段1，用卡的效果才能特殊召唤。
-- ①：这张卡1回合最多2次不会被战斗破坏。
-- ②：只要这张卡在怪兽区域存在，回合玩家只能有最多和那个回合攻击过的次数相同次数把怪兽特殊召唤。
function c29951323.initial_effect(c)
	-- 这张卡不能通常召唤，在自己没有进行特殊召唤的自己主要阶段1，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c29951323.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡1回合最多2次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(2)
	e2:SetValue(c29951323.valcon)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，回合玩家只能有最多和那个回合攻击过的次数相同次数把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c29951323.limittg)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，回合玩家只能有最多和那个回合攻击过的次数相同次数把怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetCondition(c29951323.countcon1)
	e4:SetValue(c29951323.countval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCondition(c29951323.countcon2)
	e5:SetTargetRange(0,1)
	c:RegisterEffect(e5)
end
-- 判定此卡能否用卡的效果特殊召唤：必须是由入连锁的卡的效果进行特殊召唤，且此卡控制者本回合未进行过特殊召唤，并且当前是自己回合的主要阶段1。
function c29951323.splimit(e,se,sp,st)
	-- 特殊召唤条件之一：发动特殊召唤的效果是入连锁的卡的效果，且此卡控制者本回合的特殊召唤次数为0。
	return se:IsHasType(EFFECT_TYPE_ACTIONS) and Duel.GetActivityCount(e:GetHandlerPlayer(),ACTIVITY_SPSUMMON)==0
		-- 特殊召唤条件之二：当前阶段必须为主要阶段1，且当前回合玩家必须是此卡控制者。
		and Duel.GetCurrentPhase()==PHASE_MAIN1 and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 该函数用于判定战斗破坏抗性效果的适用：检查破坏原因中是否包含战斗破坏（REASON_BATTLE），只有战斗破坏才会计入本次不破坏次数并适用。
function c29951323.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 该函数是②效果的禁止特殊召唤判定：若当前回合玩家正是要特殊召唤的玩家，且其本回合已经特殊召唤的次数不少于本回合攻击次数，则该次特殊召唤被禁止。
function c29951323.limittg(e,c,tp)
	-- 当特殊召唤玩家的本回合特殊召唤次数已经大于等于攻击次数时，返回true以禁止其再特殊召唤。
	return Duel.GetTurnPlayer()==tp and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)>=Duel.GetBattledCount(tp)
end
-- e4的发动条件：只在当前回合玩家为此卡控制者（即控制者的回合）时，才应用对自己玩家的剩余特殊召唤次数限制。
function c29951323.countcon1(e)
	-- 判断当前回合玩家是否为此卡控制者，若是则满足条件。
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- e5的条件：只在当前回合玩家不是此卡控制者（即对手回合）时，才应用对对方玩家的剩余特殊召唤次数限制。
function c29951323.countcon2(e)
	-- 判断当前回合玩家是否不是此卡控制者，若是则满足条件。
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- 计算该玩家本回合剩余可特殊召唤次数：为本回合攻击次数减去已特殊召唤次数；若已特殊召唤次数不少于攻击次数，则剩余次数为0。
function c29951323.countval(e,re,tp)
	-- 获取该玩家本回合已经进行的特殊召唤次数，作为已使用次数t1。
	local t1=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
	-- 获取该玩家本回合已经攻击过的次数，作为上限基准t2。
	local t2=Duel.GetBattledCount(tp)
	if t1>=t2 then return 0 else return t2-t1 end
end
