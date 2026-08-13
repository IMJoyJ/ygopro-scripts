--ドラゴノイド・ジェネレーター
-- 效果：
-- 支付1000基本分才能把这张卡发动。这个卡名的①的效果1回合可以使用最多2次。
-- ①：自己主要阶段才能发动。把1只「机龙衍生物」（机械族·地·1星·攻/守300）在自己场上攻击表示特殊召唤。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。这个回合的结束阶段，对方必须把1只「机龙衍生物」在自身场上攻击表示特殊召唤。
function c28053763.initial_effect(c)
	-- 支付1000基本分才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c28053763.cost)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合可以使用最多2次。①：自己主要阶段才能发动。把1只「机龙衍生物」（机械族·地·1星·攻/守300）在自己场上攻击表示特殊召唤。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。这个回合的结束阶段，对方必须把1只「机龙衍生物」在自身场上攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28053763,0))  --"特殊召唤衍生物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(2,28053763)
	e2:SetTarget(c28053763.tktg)
	e2:SetOperation(c28053763.tkop)
	c:RegisterEffect(e2)
end
-- 发动这张卡时的代价处理：在效果发动前检查并支付1000基本分。
function c28053763.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段，判定当前玩家能否支付1000基本分作为发动代价。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际扣除当前玩家1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- ①效果的发动条件与目标条件判定：检查自己场上是否有怪兽区空位，以及自己能否特殊召唤「机龙衍生物」。
function c28053763.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在空位，用于后续特殊召唤衍生物。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己能否特殊召唤符合条件的「机龙衍生物」（机械族·地·1星·攻/守300，表侧攻击表示）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28053764,0,TYPES_TOKEN_MONSTER,300,300,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) end
	-- 设置操作信息：本效果将产生1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本效果将进行1次特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ①效果处理流程：先给自己附加“不能从额外卡组特殊召唤”的限制，然后在自己场上攻击表示特殊召唤1只「机龙衍生物」，并注册结束阶段让对方特招衍生物的效果。
function c28053763.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 把1只「机龙衍生物」（机械族·地·1星·攻/守300）在自己场上攻击表示特殊召唤。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。这个回合的结束阶段，对方必须把1只「机龙衍生物」在自身场上攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 设置不能特殊召唤的限制对象：位于额外卡组的怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_EXTRA))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能从额外卡组把怪兽特殊召唤”的永续效果注册到当前玩家（自己）身上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- 处理特招时再次确认自己怪兽区是否有空位，若无空位则终止特招部分。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 处理特招时再次确认自己能否特殊召唤「机龙衍生物」，若不能则终止特招部分。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,28053764,0,TYPES_TOKEN_MONSTER,300,300,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) then return end
	-- 创建1只「机龙衍生物」（卡号28053764）到自己场上。
	local token=Duel.CreateToken(tp,28053764)
	-- 将「机龙衍生物」以表侧攻击表示特殊召唤到自己场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	-- 这个回合的结束阶段，对方必须把1只「机龙衍生物」在自身场上攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28053763,1))  --"对方必须把1只「机龙衍生物」在自身场上攻击表示特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetOperation(c28053763.tkop2)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将结束阶段强制对方特殊召唤衍生物的效果注册到场上，并使其在回合结束时重置。
	Duel.RegisterEffect(e2,tp)
end
-- 结束阶段处理：在对方场上攻击表示特殊召唤1只「机龙衍生物」。
function c28053763.tkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方怪兽区是否有空位，若没有空位则不处理。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	-- 检查对方能否特殊召唤「机龙衍生物」，若不能则不处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(1-tp,28053764,0,TYPES_TOKEN_MONSTER,300,300,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) then return end
	-- 向双方展示「机龙生成器」的卡片动画，提示正在进行该效果处理。
	Duel.Hint(HINT_CARD,0,28053763)
	-- 为对方创建1只「机龙衍生物」。
	local token=Duel.CreateToken(1-tp,28053764)
	-- 将「机龙衍生物」以表侧攻击表示特殊召唤到对方场上。
	Duel.SpecialSummon(token,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK)
end
