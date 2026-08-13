--サモンリミッター
-- 效果：
-- ①：这个回合中对怪兽的召唤·反转召唤·特殊召唤已有合计2次以上成功的玩家只要这张卡在魔法与陷阱区域存在，不能把怪兽召唤·反转召唤·特殊召唤。
function c23516703.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①效果中‘这个回合中对怪兽的召唤·反转召唤·特殊召唤已有合计2次以上成功的玩家……不能把怪兽召唤’部分，即对‘召唤’的禁止；limittg判断玩家本回合三类召唤合计次数是否达到2次以上。
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
	-- ①效果中‘不能把怪兽特殊召唤’的辅助实现：通过EFFECT_LEFT_SPSUMMON_COUNT将剩余特殊召唤次数设为0，使达到条件的玩家无法特殊召唤怪兽。
	local et=Effect.CreateEffect(c)
	et:SetType(EFFECT_TYPE_FIELD)
	et:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	et:SetRange(LOCATION_SZONE)
	et:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	et:SetTargetRange(1,1)
	et:SetValue(c23516703.countval)
	c:RegisterEffect(et)
end
-- 规则判定函数：当玩家tp本回合的召唤、反转召唤、特殊召唤合计次数达到2次以上时，返回真，使对应召唤/反转召唤/特殊召唤的禁止效果生效。
function c23516703.limittg(e,c,tp)
	-- 分别获取玩家tp本回合的召唤次数t1、反转召唤次数t2、特殊召唤次数t3，以计算合计次数。
	local t1,t2,t3=Duel.GetActivityCount(tp,ACTIVITY_SUMMON,ACTIVITY_FLIPSUMMON,ACTIVITY_SPSUMMON)
	return t1+t2+t3>=2
end
-- 规则判定函数：计算并返回玩家tp当前剩余可进行的特殊召唤次数；若三类召唤合计已达2次则返回0（禁止特殊召唤），否则返回2减去合计次数。
function c23516703.countval(e,re,tp)
	-- 分别获取玩家tp本回合的召唤次数t1、反转召唤次数t2、特殊召唤次数t3，用于计算特殊召唤剩余次数。
	local t1,t2,t3=Duel.GetActivityCount(tp,ACTIVITY_SUMMON,ACTIVITY_FLIPSUMMON,ACTIVITY_SPSUMMON)
	if t1+t2+t3>=2 then return 0 else return 2-t1-t2-t3 end
end
