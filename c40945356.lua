--黄昏の中忍－ニチリン
-- 效果：
-- 这张卡在规则上也当作「忍者」卡使用。
-- ①：1回合1次，可以从手卡丢弃1只「忍者」怪兽，从以下效果选择1个发动。这个效果在对方回合也能发动。
-- ●这个回合，自己场上的「忍者」怪兽以及「忍法」卡不会被战斗·效果破坏。
-- ●选自己场上1只「忍者」怪兽，那个攻击力直到回合结束时上升1000。
function c40945356.initial_effect(c)
	-- ①：1回合1次，可以从手卡丢弃1只「忍者」怪兽，从以下效果选择1个发动。这个效果在对方回合也能发动。●这个回合，自己场上的「忍者」怪兽以及「忍法」卡不会被战斗·效果破坏。
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
	-- ①：1回合1次，可以从手卡丢弃1只「忍者」怪兽，从以下效果选择1个发动。这个效果在对方回合也能发动。●选自己场上1只「忍者」怪兽，那个攻击力直到回合结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40945356,1))  --"攻击上升1000"
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	-- 设置该效果的发动条件：在伤害步骤中仅限伤害计算前发动（结合伤害步骤限制，可在对方回合的伤害步骤中发动该攻击力上升效果）。
	e2:SetCondition(aux.dscon)
	e2:SetCost(c40945356.cost)
	e2:SetTarget(c40945356.target2)
	e2:SetOperation(c40945356.operation2)
	c:RegisterEffect(e2)
end
-- 定义代价筛选条件：手卡中属于「忍者」字段的怪兽卡，且可以作为代价被丢弃。
function c40945356.cfilter(c)
	return c:IsSetCard(0x2b) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 代价处理：从手卡选择并丢弃1只「忍者」怪兽作为发动代价，丢弃原因同时包含代价和丢弃。
function c40945356.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己手卡中存在至少1只满足代价筛选条件的「忍者」怪兽，才能发动该效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c40945356.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：玩家tp从手卡选择1只「忍者」怪兽丢弃，作为发动效果的代价（原因REASON_COST+REASON_DISCARD）。
	Duel.DiscardHand(tp,c40945356.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 保护对象筛选：用于判断卡是否为表侧表示的「忍法」卡，或表侧表示的「忍者」怪兽卡，作为破坏耐性效果的适用对象。
function c40945356.indfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x61) or (c:IsSetCard(0x2b) and c:IsType(TYPE_MONSTER)))
end
-- 第一个效果发动合法性检查：确认自己场上存在至少1张满足indfilter条件的「忍者」怪兽或「忍法」卡，避免空发。
function c40945356.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：自己场上是否存在至少1张表侧表示的「忍法」卡或表侧表示的「忍者」怪兽卡，作为效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c40945356.indfilter,tp,LOCATION_ONFIELD,0,1,nil) end
end
-- 效果处理：给己方场上满足条件的「忍者」怪兽附加“不会被战斗破坏”，给己方场上满足条件的「忍者」怪兽及「忍法」卡附加“不会被效果破坏”，均持续到回合结束。
function c40945356.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 「●这个回合，自己场上的「忍者」怪兽以及「忍法」卡不会被战斗·效果破坏。」中的“不会被战斗破坏”部分。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c40945356.indtg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 将领域效果e1注册到场上，使己方场上符合条件的「忍者」怪兽获得“不会被战斗破坏”的适用状态，直到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- ①：1回合1次，可以从手卡丢弃1只「忍者」怪兽，从以下效果选择1个发动。这个效果在对方回合也能发动。●这个回合，自己场上的「忍者」怪兽以及「忍法」卡不会被战斗·效果破坏。●选自己场上1只「忍者」怪兽，那个攻击力直到回合结束时上升1000。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c40945356.indtg)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 将领域效果e2注册到场上，使己方场上符合条件的「忍者」怪兽和「忍法」卡获得“不会被效果破坏”的适用状态，直到回合结束。
	Duel.RegisterEffect(e2,tp)
end
-- 判断卡片是否属于「忍法」卡，或属于「忍者」字段的怪兽卡，用于两个耐性效果的适用目标判定。
function c40945356.indtg(e,c)
	return c:IsSetCard(0x61) or (c:IsSetCard(0x2b) and c:IsType(TYPE_MONSTER))
end
-- 攻击力上升效果的目标筛选：己方场上表侧表示的「忍者」字段怪兽。
function c40945356.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2b)
end
-- 第二个效果发动合法性检查：确认自己场上存在至少1只表侧表示的「忍者」怪兽，以便选择对象并使其攻击力上升。
function c40945356.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己场上是否存在至少1只表侧表示的「忍者」怪兽，满足攻击力上升效果的对象要求。
	if chk==0 then return Duel.IsExistingMatchingCard(c40945356.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：选择自己场上1只表侧表示的「忍者」怪兽，令其攻击力直到回合结束时上升1000。
function c40945356.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，告知玩家需要选择1张表侧表示的卡（此处为表侧表示的「忍者」怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家从自己场上表侧表示的「忍者」怪兽中选择1只，作为攻击力上升效果的对象。
	local g=Duel.SelectMatchingCard(tp,c40945356.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 「●选自己场上1只「忍者」怪兽，那个攻击力直到回合结束时上升1000。」中的“那个攻击力直到回合结束时上升1000”部分。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
