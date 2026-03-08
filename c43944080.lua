--ネムレリアの夢守り－クエット
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己的额外卡组有表侧表示的灵摆怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在，自己场上的「妮穆蕾莉娅」卡为对象的效果由对方发动时，从额外卡组把1张里侧表示的卡里侧表示除外才能发动。那个发动无效。
function c43944080.initial_effect(c)
	-- ①：自己的额外卡组有表侧表示的灵摆怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,43944080+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c43944080.sprcon)
	c:RegisterEffect(e1)
	-- ②：自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在，自己场上的「妮穆蕾莉娅」卡为对象的效果由对方发动时，从额外卡组把1张里侧表示的卡里侧表示除外才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43944080,0))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,43944081)
	e2:SetCondition(c43944080.discon)
	e2:SetCost(c43944080.discost)
	e2:SetTarget(c43944080.distg)
	e2:SetOperation(c43944080.disop)
	c:RegisterEffect(e2)
end
-- 检查手卡特殊召唤的条件：场上是否有空位且额外卡组存在灵摆怪兽。
function c43944080.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查手卡特殊召唤的条件：场上是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡特殊召唤的条件：额外卡组是否存在表侧表示的灵摆怪兽。
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_EXTRA,0,1,nil,TYPE_PENDULUM)
end
-- 过滤函数：用于判断目标是否为己方场上的表侧表示的妮穆蕾莉娅卡。
function c43944080.tfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(0x191) and c:IsControler(tp) and c:IsFaceup()
end
-- 效果发动条件判断：对方发动效果时，若己方额外卡组存在梦见之妮穆蕾莉娅，且效果对象包含己方场上的妮穆蕾莉娅卡，则可以发动此效果。
function c43944080.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 效果发动条件判断：检查己方额外卡组是否存在表侧表示的梦见之妮穆蕾莉娅。
	if not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_EXTRA,0,1,nil,70155677) then return false end
	-- 获取当前连锁的效果对象卡片组。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 效果发动条件判断：判断效果对象中是否存在己方场上的妮穆蕾莉娅卡，且该连锁可以被无效。
	return tg and tg:IsExists(c43944080.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 过滤函数：用于判断额外卡组中是否存在可作为除外代价的里侧表示的卡。
function c43944080.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
-- 支付效果代价：从额外卡组选择一张里侧表示的卡除外作为代价。
function c43944080.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取额外卡组中所有可作为除外代价的里侧表示的卡。
	local g=Duel.GetMatchingGroup(c43944080.rmfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>0 end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:Select(tp,1,1,nil)
	-- 将选择的卡从游戏中除外。
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
end
-- 设置效果处理时的操作信息：使发动无效。
function c43944080.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时的操作信息：使发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果处理函数：使连锁发动无效。
function c43944080.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效。
	Duel.NegateActivation(ev)
end
