--氷水帝コスモクロア
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：场地区域有表侧表示卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：只要场上有「冰水底 铬离子少女摇篮」存在，对方不能把除这个回合召唤·反转召唤·特殊召唤的怪兽外的场上的怪兽的效果发动。
-- ③：只在自己的「冰水」怪兽和对方怪兽进行战斗的伤害计算时，那只对方怪兽的攻击力下降1000。
function c3355732.initial_effect(c)
	-- 记录该卡牌效果中涉及的另一张卡牌编号
	aux.AddCodeList(c,7142724)
	-- ①：场地区域有表侧表示卡存在的场合，这张卡可以从手卡特殊召唤。
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
-- 判断是否满足特殊召唤条件：手牌中的卡能否特殊召唤到场上
function c3355732.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断手牌中的卡是否能特殊召唤到场上（是否有足够的怪兽区域）
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场地区域是否存在表侧表示的卡
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 判断场地卡「冰水底 铬离子少女摇篮」是否在场
function c3355732.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场地卡「冰水底 铬离子少女摇篮」是否在场
	return Duel.IsEnvironment(7142724)
end
-- 限制对方怪兽在非召唤/反转/特殊召唤的场合发动效果
function c3355732.actlimit(e,c)
	return not c:IsStatus(STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
-- 判断是否处于伤害计算阶段且己方「冰水」怪兽正在与对方怪兽战斗
function c3355732.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取当前正在战斗的双方怪兽
	local a,d=Duel.GetBattleMonster(tp)
	-- 判断是否处于伤害计算阶段且己方「冰水」怪兽正在与对方怪兽战斗
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and a and d and a:IsSetCard(0x16c)
end
-- 设定攻击下降效果的目标怪兽为正在战斗的对方怪兽
function c3355732.atktg(e,c)
	local tp=e:GetHandlerPlayer()
	-- 获取当前正在战斗的双方怪兽
	local a,d=Duel.GetBattleMonster(tp)
	return c==d
end
