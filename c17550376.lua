--ネムレリアの夢守り－オレイエ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己的额外卡组有表侧表示的灵摆怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在的场合，从额外卡组把1张里侧表示的卡里侧表示除外才能发动。这张卡的攻击力直到回合结束时上升对方场上的怪兽数量×500。这个效果在对方回合也能发动。
function c17550376.initial_effect(c)
	-- ①：自己的额外卡组有表侧表示的灵摆怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,17550376+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c17550376.sprcon)
	c:RegisterEffect(e1)
	-- ②：自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在的场合，从额外卡组把1张里侧表示的卡里侧表示除外才能发动。这张卡的攻击力直到回合结束时上升对方场上的怪兽数量×500。这个效果在对方回合也能发动。
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
-- 判断是否满足特殊召唤条件：场上存在空位且额外卡组存在表侧表示的灵摆怪兽。
function c17550376.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否有可用怪兽区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家额外卡组是否存在至少1张表侧表示的灵摆怪兽。
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_EXTRA,0,1,nil,TYPE_PENDULUM)
end
-- 判断是否满足攻击力上升效果的发动条件：当前不在伤害步骤且对方场上有怪兽存在且额外卡组存在表侧表示的妮穆蕾莉娅。
function c17550376.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否处于非伤害步骤或伤害步骤但尚未进行伤害计算。
	return aux.dscon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查玩家额外卡组是否存在至少1张表侧表示的「梦见之妮穆蕾莉娅」。
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_EXTRA,0,1,nil,70155677)
end
-- 用于筛选可以作为除外代价的卡：必须是里侧表示且可以被除外。
function c17550376.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
-- 处理效果发动的除外代价：从额外卡组选择1张里侧表示的卡除外。
function c17550376.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家额外卡组中所有满足除外条件的卡。
	local g=Duel.GetMatchingGroup(c17550376.rmfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>0 end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:Select(tp,1,1,nil)
	-- 将选中的卡以里侧表示的形式除外。
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
end
-- 执行攻击力上升效果：根据对方场上的怪兽数量增加自身攻击力。
function c17550376.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的怪兽数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if c:IsFaceup() and c:IsRelateToEffect(e) and ct>0 then
		-- 将攻击力提升效果登记到自身卡上，提升值为对方场上的怪兽数量乘以500，并在回合结束时重置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
