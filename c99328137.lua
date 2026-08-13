--氷騎士
-- 效果：
-- ①：这张卡的攻击力上升自己场上的水族怪兽数量×400。
-- ②：1回合1次，自己主要阶段才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只水属性怪兽召唤。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能召唤·特殊召唤。
function c99328137.initial_effect(c)
	-- ①：这张卡的攻击力上升自己场上的水族怪兽数量×400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c99328137.val)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只水属性怪兽召唤。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99328137,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c99328137.sumtg)
	e2:SetOperation(c99328137.sumop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为表侧表示存在且种族为水族，用于统计自己场上水族怪兽的数量。
function c99328137.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA)
end
-- 攻击力变化值的计算函数：以控制者视角统计其场上表侧表示水族怪兽数量，再乘以400，作为攻击力上升的数值。
function c99328137.val(e,c)
	-- 获取自己场上表侧表示水族怪兽的数量，乘以400，得到这张卡的攻击力上升值。
	return Duel.GetMatchingGroupCount(c99328137.cfilter,c:GetControler(),LOCATION_MZONE,0,nil)*400
end
-- ②效果的发动条件判断：确认自己可以通常召唤、有额外召唤次数，且本回合尚未发动过“冰骑士”的效果。
function c99328137.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件检查的第一部分：玩家可以进行通常召唤且玩家拥有额外的通常召唤次数。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 条件检查的第二部分：玩家没有标记效果99328137，即本回合还未使用过“冰骑士”的②效果（1回合1次限制）。
		and Duel.GetFlagEffect(tp,99328137)==0 end
end
-- ②效果的发动处理：为玩家赋予本回合追加一次水属性通常召唤的机会，并对非水属性怪兽的召唤·特殊召唤施加限制。
function c99328137.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否已经有标志效果94076521，若没有才进行后续的额外召唤次数赋予，避免重复处理。
	if Duel.GetFlagEffect(tp,94076521)==0 then
		-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只水属性怪兽召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(99328137,1))  --"使用「冰骑士」的效果召唤"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTarget(c99328137.extrasumtg)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将额外召唤次数效果e1注册给玩家，使玩家本回合在通常召唤外增加一次召唤机会（目标为水属性怪兽）。
		Duel.RegisterEffect(e1,tp)
		-- 为玩家注册标记效果99328137，在结束阶段重置，用于记录本回合已发动过“冰骑士”的②效果，保证1回合只能使用1次。
		Duel.RegisterFlagEffect(tp,99328137,RESET_PHASE+PHASE_END,0,1)
	end
	-- 这个效果的发动后，直到回合结束时自己不是水属性怪兽不能召唤·特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c99328137.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能召唤非水属性怪兽”的限制效果e2注册给玩家，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 将“不能特殊召唤非水属性怪兽”的限制效果e3注册给玩家，持续到回合结束。
	Duel.RegisterEffect(e3,tp)
end
-- 额外召唤的目标过滤函数：只有水属性怪兽才能使用本次额外召唤次数。
function c99328137.extrasumtg(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
-- 自肃限制的过滤函数：非水属性怪兽不能进行召唤或特殊召唤。
function c99328137.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
