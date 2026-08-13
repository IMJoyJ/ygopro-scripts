--ネムレリアの夢守り－オレイエ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己的额外卡组有表侧表示的灵摆怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在的场合，从额外卡组把1张里侧表示的卡里侧表示除外才能发动。这张卡的攻击力直到回合结束时上升对方场上的怪兽数量×500。这个效果在对方回合也能发动。
function c17550376.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次；①：自己的额外卡组有表侧表示的灵摆怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,17550376+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c17550376.sprcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次；②：自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在的场合，从额外卡组把1张里侧表示的卡里侧表示除外才能发动。这张卡的攻击力直到回合结束时上升对方场上的怪兽数量×500。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17550376,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1,17550377)
	e2:SetCondition(c17550376.atkcon)
	e2:SetCost(c17550376.atkcost)
	e2:SetOperation(c17550376.atkop)
	c:RegisterEffect(e2)
end
-- ①特殊召唤规则效果的召唤条件判定：当c为nil时表示询问规则召唤是否可用，返回true；否则确认召唤者tp有可用的主要怪兽区空格，且自己的额外卡组存在至少1张表侧表示的灵摆怪兽，满足这两点才允许这张卡从手卡以规则方式特殊召唤。
function c17550376.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己的主要怪兽区是否有空余区域，以确保这张卡特殊召唤时有可用位置。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的额外卡组是否存在至少1张表侧表示的灵摆怪兽，满足①效果规定的特殊召唤前提。
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_EXTRA,0,1,nil,TYPE_PENDULUM)
end
-- ②诱发即时效果的发动条件判定：需要满足当前非伤害步骤或未进行伤害计算、对方场上有怪兽存在，并且自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」（卡号70155677），才允许发动。
function c17550376.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认不是伤害步骤或未进入伤害计算，且对方场上有怪兽，从而符合②效果能在对方回合发动且至少能上升500攻击力的条件。
	return aux.dscon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 确认自己的额外卡组存在表侧表示的「梦见之妮穆蕾莉娅」（卡号70155677），这是发动②效果的必要条件。
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_EXTRA,0,1,nil,70155677)
end
-- 定义代价选择筛选函数：只选择额外卡组中里侧表示且可以作为里侧表示除外代价的卡。
function c17550376.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
-- ②效果的代价处理：从自己的额外卡组选择1张里侧表示的卡，以里侧表示除外作为发动代价。chk==0时只检查是否存在可选代价，否则让玩家选择并执行除外。
function c17550376.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己额外卡组中所有满足条件（里侧表示且可作为里侧除外代价）的候选卡集合，供后续选择使用。
	local g=Duel.GetMatchingGroup(c17550376.rmfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>0 end
	-- 在让玩家选择代价卡片前，给出“请选择要除外的卡”的选择提示，并指定提示类型为除外选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:Select(tp,1,1,nil)
	-- 将玩家选定的那1张卡以里侧表示除外，作为发动②效果所支付的代价（REASON_COST）。
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
end
-- ②效果的处理：获取效果持有者自身，统计对方场上的怪兽数量；若本卡仍然表侧表示且与效果关联，且对方怪兽数大于0，则给本卡赋予攻击力上升效果，上升值为对方怪兽数×500，持续到回合结束。
function c17550376.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 统计对方场上的怪兽数量，作为攻击力上升幅度的计算基数。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if c:IsFaceup() and c:IsRelateToEffect(e) and ct>0 then
		-- 这张卡的攻击力直到回合结束时上升对方场上的怪兽数量×500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
