--スプライト・ピクシーズ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有2星或者2阶的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：其他的自己的2星·2阶·连接2的怪兽和对方怪兽进行战斗的伤害计算时，把手卡·场上的这张卡送去墓地才能发动。那只自己怪兽的攻击力·守备力直到回合结束时上升那只对方怪兽的攻击力数值。
function c49928686.initial_effect(c)
	-- ①：自己场上有2星或者2阶的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49928686,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,49928686+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c49928686.spcon)
	c:RegisterEffect(e1)
	-- ②：其他的自己的2星·2阶·连接2的怪兽和对方怪兽进行战斗的伤害计算时，把手卡·场上的这张卡送去墓地才能发动。那只自己怪兽的攻击力·守备力直到回合结束时上升那只对方怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49928686,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e2:SetCountLimit(1,49928687)
	e2:SetCondition(c49928686.atkcon)
	e2:SetCost(c49928686.atkcost)
	e2:SetOperation(c49928686.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在2星或2阶的怪兽。
function c49928686.filter(c)
	return (c:IsLevel(2) or c:IsRank(2)) and c:IsFaceup()
end
-- 特殊召唤条件函数，检查是否满足特殊召唤要求。
function c49928686.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查玩家场上是否存在至少1只2星或2阶的怪兽。
		and Duel.IsExistingMatchingCard(c49928686.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 攻击变化效果的发动条件函数，判断是否满足发动条件。
function c49928686.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在战斗中的自己怪兽和对方怪兽。
	local a,d=Duel.GetBattleMonster(tp)
	return a and d and (a:IsLevel(2) or a:IsRank(2) or a:IsLink(2)) and a~=e:GetHandler()
end
-- 攻击变化效果的费用支付函数，将自身送去墓地作为代价。
function c49928686.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为效果的发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 攻击变化效果的实际执行函数，使指定怪兽在伤害计算时获得攻击力和守备力加成。
function c49928686.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在战斗中的自己怪兽和对方怪兽。
	local a,d=Duel.GetBattleMonster(tp)
	if not a:IsRelateToBattle() or not d:IsRelateToBattle() then return end
	-- 为指定怪兽添加攻击力增加效果，数值等于对方怪兽的攻击力。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(d:GetAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	a:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	a:RegisterEffect(e2)
end
