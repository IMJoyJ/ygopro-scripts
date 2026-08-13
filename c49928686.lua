--スプライト・ピクシーズ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有2星或者2阶的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：其他的自己的2星·2阶·连接2的怪兽和对方怪兽进行战斗的伤害计算时，把手卡·场上的这张卡送去墓地才能发动。那只自己怪兽的攻击力·守备力直到回合结束时上升那只对方怪兽的攻击力数值。
function c49928686.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有2星或者2阶的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49928686,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,49928686+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c49928686.spcon)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次。②：其他的自己的2星·2阶·连接2的怪兽和对方怪兽进行战斗的伤害计算时，把手卡·场上的这张卡送去墓地才能发动。那只自己怪兽的攻击力·守备力直到回合结束时上升那只对方怪兽的攻击力数值。
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
-- 过滤函数：判断怪兽是否为表侧表示且等级为2或阶级为2，用于检查场上是否存在满足①特殊召唤条件的怪兽。
function c49928686.filter(c)
	return (c:IsLevel(2) or c:IsRank(2)) and c:IsFaceup()
end
-- ①特殊召唤规则的条件：若没有传入具体卡片则返回true以允许系统检索可特殊召唤的卡；否则检查自己主要怪兽区有空位，且自己场上有表侧表示的等级2或阶级2的怪兽。
function c49928686.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者的主要怪兽区是否有空位，供①从手卡特殊召唤使用。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查该控制者的主要怪兽区是否存在至少1张表侧表示且等级2或阶级2的怪兽，以满足①的召唤条件。
		and Duel.IsExistingMatchingCard(c49928686.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- ②的发动条件：伤害计算时存在我方战斗怪兽a和对方战斗怪兽d，且a是等级2/阶级2/连接2的怪兽，并且a不是这张卡自身（即“其他的”自己的符合条件的怪兽）。
function c49928686.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前由tp操控的战斗怪兽a，以及对方与之战斗的怪兽d；若没有战斗或战斗对象不存在则取不到。
	local a,d=Duel.GetBattleMonster(tp)
	return a and d and (a:IsLevel(2) or a:IsRank(2) or a:IsLink(2)) and a~=e:GetHandler()
end
-- ②的代价判定与支付：chk==0时确认这张卡能否作为代价送去墓地；确定发动后将这张卡自身从手卡或场上送去墓地作为代价。
function c49928686.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡自身送去墓地，作为②效果发动的代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ②效果处理：确认战斗双方怪兽仍与本次战斗相关后，给己方战斗怪兽附加攻击力上升效果，上升值为对方战斗怪兽当前的攻击力，持续到回合结束时；随后再克隆一个相同数值的守备力上升效果。
function c49928686.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的己方怪兽a和对方怪兽d，用于计算对方攻击力数值并赋予己方怪兽。
	local a,d=Duel.GetBattleMonster(tp)
	if not a:IsRelateToBattle() or not d:IsRelateToBattle() then return end
	-- 那只自己怪兽的攻击力直到回合结束时上升那只对方怪兽的攻击力数值。
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
