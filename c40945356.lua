--黄昏の中忍－ニチリン
-- 效果：
-- 这张卡在规则上也当作「忍者」卡使用。
-- ①：1回合1次，可以从手卡丢弃1只「忍者」怪兽，从以下效果选择1个发动。这个效果在对方回合也能发动。
-- ●这个回合，自己场上的「忍者」怪兽以及「忍法」卡不会被战斗·效果破坏。
-- ●选自己场上1只「忍者」怪兽，那个攻击力直到回合结束时上升1000。
function c40945356.initial_effect(c)
	-- 效果原文内容：①：1回合1次，可以从手卡丢弃1只「忍者」怪兽，从以下效果选择1个发动。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40945356,0))  --"破坏耐性"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCost(c40945356.cost)
	e1:SetTarget(c40945356.target1)
	e1:SetOperation(c40945356.operation1)
	c:RegisterEffect(e1)
	-- 效果原文内容：●这个回合，自己场上的「忍者」怪兽以及「忍法」卡不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40945356,1))  --"攻击上升1000"
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	-- 规则层面操作：限制效果只能在伤害计算前发动或适用。
	e2:SetCondition(aux.dscon)
	e2:SetCost(c40945356.cost)
	e2:SetTarget(c40945356.target2)
	e2:SetOperation(c40945356.operation2)
	c:RegisterEffect(e2)
end
-- 规则层面操作：过滤函数，用于判断手牌中是否存在满足条件的「忍者」怪兽。
function c40945356.cfilter(c)
	return c:IsSetCard(0x2b) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 规则层面操作：执行丢弃手牌中满足条件的「忍者」怪兽的处理。
function c40945356.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否满足丢弃条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c40945356.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面操作：从手牌中丢弃1张满足条件的卡。
	Duel.DiscardHand(tp,c40945356.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 规则层面操作：过滤函数，用于判断场上是否存在满足条件的「忍者」或「忍法」怪兽。
function c40945356.indfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x61) or (c:IsSetCard(0x2b) and c:IsType(TYPE_MONSTER)))
end
-- 规则层面操作：检查是否满足发动条件。
function c40945356.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查场上是否存在满足条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c40945356.indfilter,tp,LOCATION_ONFIELD,0,1,nil) end
end
-- 规则层面操作：注册两个效果，使自己场上的「忍者」怪兽和「忍法」卡在本回合内不会被战斗和效果破坏。
function c40945356.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：●选自己场上1只「忍者」怪兽，那个攻击力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c40945356.indtg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 规则层面操作：将效果e1注册给玩家tp。
	Duel.RegisterEffect(e1,tp)
	-- 效果原文内容：●选自己场上1只「忍者」怪兽，那个攻击力直到回合结束时上升1000。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c40945356.indtg)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 规则层面操作：将效果e2注册给玩家tp。
	Duel.RegisterEffect(e2,tp)
end
-- 规则层面操作：过滤函数，用于判断场上卡是否为「忍法」或「忍者」怪兽。
function c40945356.indtg(e,c)
	return c:IsSetCard(0x61) or (c:IsSetCard(0x2b) and c:IsType(TYPE_MONSTER))
end
-- 规则层面操作：过滤函数，用于判断场上是否存在满足条件的「忍者」怪兽。
function c40945356.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2b)
end
-- 规则层面操作：检查是否满足发动条件。
function c40945356.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查场上是否存在满足条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c40945356.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 规则层面操作：选择场上满足条件的「忍者」怪兽，使其攻击力上升1000。
function c40945356.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示玩家选择场上表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 规则层面操作：选择场上满足条件的1张卡。
	local g=Duel.SelectMatchingCard(tp,c40945356.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 规则层面操作：使目标怪兽的攻击力上升1000点
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
