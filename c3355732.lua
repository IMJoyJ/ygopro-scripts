--氷水帝コスモクロア
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：场地区域有表侧表示卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：只要场上有「冰水底 铬离子少女摇篮」存在，对方不能把除这个回合召唤·反转召唤·特殊召唤的怪兽外的场上的怪兽的效果发动。
-- ③：只在自己的「冰水」怪兽和对方怪兽进行战斗的伤害计算时，那只对方怪兽的攻击力下降1000。
function c3355732.initial_effect(c)
	-- 将卡号7142724（「冰水底 铬离子少女摇篮」）记录为这张卡上记载的卡名，供检索/判定使用。
	aux.AddCodeList(c,7142724)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：场地区域有表侧表示卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,3355732+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c3355732.spcon)
	c:RegisterEffect(e1)
	-- ②：只要场上有「冰水底 铬离子少女摇篮」存在，对方不能把除这个回合召唤·反转召唤·特殊召唤的怪兽外的场上的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c3355732.actcon)
	e2:SetTarget(c3355732.actlimit)
	c:RegisterEffect(e2)
	-- ③：只在自己的「冰水」怪兽和对方怪兽进行战斗的伤害计算时，那只对方怪兽的攻击力下降1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c3355732.atkcon)
	e3:SetTarget(c3355732.atktg)
	e3:SetValue(-1000)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则的条件判断：若询问的c为空则直接视为可特殊召唤；否则需要己方主要怪兽区有空位，并且任意一方场地区存在表侧表示卡。
function c3355732.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认己方主要怪兽区存在可用的空格，作为从手卡特殊召唤的前提条件。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认至少存在1张表侧表示的场地卡（己方或对方的场地区皆可），满足①的召唤条件。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- ②效果的适用条件：场上存在「冰水底 铬离子少女摇篮」时才发动/适用。
function c3355732.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前生效的场地卡是否为卡号7142724（「冰水底 铬离子少女摇篮」）。
	return Duel.IsEnvironment(7142724)
end
-- ②效果的限制对象判定：对方场上那些本回合没有被召唤/反转召唤/特殊召唤的怪兽不能发动效果；若怪兽具有本回合被召唤/反转召唤/特殊召唤的状态，则不受此限制。
function c3355732.actlimit(e,c)
	return not c:IsStatus(STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
-- ③效果的发动条件：当前处于伤害计算阶段，且己方「冰水」怪兽与对方怪兽正在战斗。
function c3355732.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取己方正在战斗的怪兽a和对方正在战斗的怪兽d（若不存在则为nil）。
	local a,d=Duel.GetBattleMonster(tp)
	-- 确认当前为伤害计算阶段，且己方战斗怪兽a和对方战斗怪兽d都存在，并且a属于「冰水」系列（0x16c）。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and a and d and a:IsSetCard(0x16c)
end
-- ③效果的适用对象筛选：仅对对方正在战斗的那只怪兽d下降攻击力，不影响其他怪兽。
function c3355732.atktg(e,c)
	local tp=e:GetHandlerPlayer()
	-- 再次获取己方和对方正在战斗的怪兽，用于判断目标是否为对方战斗怪兽。
	local a,d=Duel.GetBattleMonster(tp)
	return c==d
end
