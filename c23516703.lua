--サモンリミッター
-- 效果：
-- ①：这个回合中对怪兽的召唤·反转召唤·特殊召唤已有合计2次以上成功的玩家只要这张卡在魔法与陷阱区域存在，不能把怪兽召唤·反转召唤·特殊召唤。
function c23516703.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这个回合中对怪兽的召唤·反转召唤·特殊召唤已有合计2次以上成功的玩家只要这张卡在魔法与陷阱区域存在，不能把怪兽召唤·反转召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c23516703.limittg)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e4)
	-- ①：这个回合中对怪兽的召唤·反转召唤·特殊召唤已有合计2次以上成功的玩家只要这张卡在魔法与陷阱区域存在，不能把怪兽召唤·反转召唤·特殊召唤。
	local et=Effect.CreateEffect(c)
	et:SetType(EFFECT_TYPE_FIELD)
	et:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	et:SetRange(LOCATION_SZONE)
	et:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	et:SetTargetRange(1,1)
	et:SetValue(c23516703.countval)
	c:RegisterEffect(et)
end
-- 判断目标玩家是否满足召唤·反转召唤·特殊召唤次数合计≥2的条件，若满足则禁止其进行召唤相关操作
function c23516703.limittg(e,c,tp)
	-- 获取目标玩家在本回合中进行的召唤、反转召唤、特殊召唤次数
	local t1,t2,t3=Duel.GetActivityCount(tp,ACTIVITY_SUMMON,ACTIVITY_FLIPSUMMON,ACTIVITY_SPSUMMON)
	return t1+t2+t3>=2
end
-- 计算目标玩家在本回合中剩余可进行的特殊召唤次数，若已达到2次则返回0，否则返回剩余次数
function c23516703.countval(e,re,tp)
	-- 获取目标玩家在本回合中进行的召唤、反转召唤、特殊召唤次数
	local t1,t2,t3=Duel.GetActivityCount(tp,ACTIVITY_SUMMON,ACTIVITY_FLIPSUMMON,ACTIVITY_SPSUMMON)
	if t1+t2+t3>=2 then return 0 else return 2-t1-t2-t3 end
end
