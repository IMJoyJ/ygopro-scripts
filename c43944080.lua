--ネムレリアの夢守り－クエット
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己的额外卡组有表侧表示的灵摆怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在，自己场上的「妮穆蕾莉娅」卡为对象的效果由对方发动时，从额外卡组把1张里侧表示的卡里侧表示除外才能发动。那个发动无效。
function c43944080.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己的额外卡组有表侧表示的灵摆怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,43944080+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c43944080.sprcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在，自己场上的「妮穆蕾莉娅」卡为对象的效果由对方发动时，从额外卡组把1张里侧表示的卡里侧表示除外才能发动。那个发动无效。
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
-- 定义①特殊召唤规则效果的发动条件：当c为nil（规则询问）时返回true表示可以处理；实际特召时，需我方主要怪兽区有空位，且我方额外卡组存在至少1张表侧表示的灵摆怪兽。
function c43944080.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查我方主要怪兽区是否有可用的空位，用于放置从手卡特殊召唤的这张卡。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方额外卡组是否存在至少1张表侧表示的灵摆怪兽，满足①效果的前置条件。
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_EXTRA,0,1,nil,TYPE_PENDULUM)
end
-- 筛选函数，用于判断一张卡是否为对方效果对象中我方场上的表侧表示「妮穆蕾莉娅」卡：必须在场上、属于0x191「妮穆蕾莉娅」字段、控制者为我方、且表侧表示。
function c43944080.tfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(0x191) and c:IsControler(tp) and c:IsFaceup()
end
-- 定义②效果的发动条件：对方发动以我方场上「妮穆蕾莉娅」卡为对象的取对象效果，且我方额外卡组有表侧表示的「梦见之妮穆蕾莉娅」、本卡未被战斗破坏确定、该连锁可被无效时，才能发动。
function c43944080.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 检查我方额外卡组是否存在表侧表示的卡号70155677（「梦见之妮穆蕾莉娅」），不存在则②效果不能发动。
	if not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_EXTRA,0,1,nil,70155677) then return false end
	-- 获取当前连锁ev中对方发动效果所选择的对象卡组，用于后续判断对象是否包含我方场上的「妮穆蕾莉娅」卡。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 确认对象卡组中存在至少1张我方场上的表侧表示「妮穆蕾莉娅」卡，且连锁ev的发动可以被无效化，两者同时满足才通过发动条件。
	return tg and tg:IsExists(c43944080.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 定义代价筛选函数：从额外卡组中选出里侧表示且可作为里侧表示除外代价的卡。
function c43944080.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
-- 定义②效果的代价：从自己额外卡组选择1张里侧表示的卡，以里侧表示除外作为发动代价；chk==0时只检查是否存在可选卡，实际支付时提示选择并除外。
function c43944080.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取我方额外卡组中所有里侧表示且可作为里侧表示除外代价的卡，作为代价候选项。
	local g=Duel.GetMatchingGroup(c43944080.rmfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>0 end
	-- 向玩家显示“请选择要除外的卡”的选卡提示，用于从候选中选择1张代价卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:Select(tp,1,1,nil)
	-- 将选中的卡以里侧表示除外，作为②效果的发动代价（REASON_COST）。
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
end
-- 定义②效果的发动目标判定：本效果不取对象，只要条件满足就允许发动；在效果处理前登记无效该连锁的操作信息。
function c43944080.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将当前连锁的触发卡eg标记为要被无效化的对象，类别为CATEGORY_NEGATE，数量1，供规则检测使用。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 定义②效果处理时的操作：执行无效对方那次效果的发动。
function c43944080.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁ev的发动无效化，即无效对方发动的那个以我方「妮穆蕾莉娅」卡为对象的效果。
	Duel.NegateActivation(ev)
end
