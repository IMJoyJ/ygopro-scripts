--放電ムスタンガン
-- 效果：
-- 这张卡不能通常召唤，在自己没有进行特殊召唤的自己主要阶段1，用卡的效果才能特殊召唤。
-- ①：这张卡1回合最多2次不会被战斗破坏。
-- ②：只要这张卡在怪兽区域存在，回合玩家只能有最多和那个回合攻击过的次数相同次数把怪兽特殊召唤。
function c29951323.initial_effect(c)
	-- 效果原文：这张卡不能通常召唤，在自己没有进行特殊召唤的自己主要阶段1，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c29951323.splimit)
	c:RegisterEffect(e1)
	-- 效果原文：①：这张卡1回合最多2次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(2)
	e2:SetValue(c29951323.valcon)
	c:RegisterEffect(e2)
	-- 效果原文：②：只要这张卡在怪兽区域存在，回合玩家只能有最多和那个回合攻击过的次数相同次数把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c29951323.limittg)
	c:RegisterEffect(e3)
	-- 效果原文：②：只要这张卡在怪兽区域存在，回合玩家只能有最多和那个回合攻击过的次数相同次数把怪兽特殊召唤。
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
-- 判断是否满足特殊召唤条件：必须是行动效果且当前回合未进行过特殊召唤，且当前阶段为主要阶段1，且当前回合玩家为该卡的持有者。
function c29951323.splimit(e,se,sp,st)
	-- 判断是否为行动效果且当前回合未进行过特殊召唤。
	return se:IsHasType(EFFECT_TYPE_ACTIONS) and Duel.GetActivityCount(e:GetHandlerPlayer(),ACTIVITY_SPSUMMON)==0
		-- 判断当前阶段是否为主要阶段1且当前回合玩家为该卡的持有者。
		and Duel.GetCurrentPhase()==PHASE_MAIN1 and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 判断是否为战斗破坏。
function c29951323.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 判断目标怪兽是否为回合玩家且其特殊召唤次数大于等于战斗次数。
function c29951323.limittg(e,c,tp)
	-- 判断当前回合玩家是否为目标玩家且其特殊召唤次数大于等于战斗次数。
	return Duel.GetTurnPlayer()==tp and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)>=Duel.GetBattledCount(tp)
end
-- 判断当前回合玩家是否为该卡持有者。
function c29951323.countcon1(e)
	-- 判断当前回合玩家是否为该卡持有者。
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 判断当前回合玩家是否不为该卡持有者。
function c29951323.countcon2(e)
	-- 判断当前回合玩家是否不为该卡持有者。
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- 计算剩余可特殊召唤次数：若特殊召唤次数大于等于战斗次数则返回0，否则返回差值。
function c29951323.countval(e,re,tp)
	-- 获取当前回合玩家的特殊召唤次数。
	local t1=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
	-- 获取当前回合玩家的战斗次数。
	local t2=Duel.GetBattledCount(tp)
	if t1>=t2 then return 0 else return t2-t1 end
end
