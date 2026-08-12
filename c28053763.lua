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
	-- ①：自己主要阶段才能发动。把1只「机龙衍生物」（机械族·地·1星·攻/守300）在自己场上攻击表示特殊召唤。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。这个回合的结束阶段，对方必须把1只「机龙衍生物」在自身场上攻击表示特殊召唤。
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
-- 检查玩家是否能支付1000点基本分
function c28053763.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000点基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000点基本分
	Duel.PayLPCost(tp,1000)
end
-- 判断是否满足特殊召唤衍生物的条件
function c28053763.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28053764,0,TYPES_TOKEN_MONSTER,300,300,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) end
	-- 设置操作信息为将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息为将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 创建并注册一个效果，使玩家在本回合不能从额外卡组特殊召唤怪兽
function c28053763.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 创建并注册一个效果，使玩家在本回合不能从额外卡组特殊召唤怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 设置效果目标为位于额外卡组的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_EXTRA))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 判断玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 判断玩家是否可以特殊召唤指定的衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,28053764,0,TYPES_TOKEN_MONSTER,300,300,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) then return end
	-- 创建一个指定编号的衍生物
	local token=Duel.CreateToken(tp,28053764)
	-- 将衍生物特殊召唤到场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	-- ①：自己主要阶段才能发动。把1只「机龙衍生物」（机械族·地·1星·攻/守300）在自己场上攻击表示特殊召唤。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。这个回合的结束阶段，对方必须把1只「机龙衍生物」在自身场上攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28053763,1))  --"对方必须把1只「机龙衍生物」在自身场上攻击表示特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetOperation(c28053763.tkop2)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 对方必须把1只「机龙衍生物」在自身场上攻击表示特殊召唤
function c28053763.tkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方场上是否有足够的怪兽区域
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	-- 判断对方是否可以特殊召唤指定的衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(1-tp,28053764,0,TYPES_TOKEN_MONSTER,300,300,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) then return end
	-- 向玩家发送提示信息，显示该卡发动动画
	Duel.Hint(HINT_CARD,0,28053763)
	-- 创建一个指定编号的衍生物
	local token=Duel.CreateToken(1-tp,28053764)
	-- 将衍生物特殊召唤到对方场上
	Duel.SpecialSummon(token,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK)
end
