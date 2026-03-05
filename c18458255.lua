--ネムレリアの寝姫楼
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从额外卡组把2张里侧表示的卡里侧表示除外才能发动。从卡组把2只卡名不同的兽族·10星怪兽加入手卡。这个效果发动的回合，自己不是灵摆怪兽不能从额外卡组特殊召唤。
-- ②：自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在，自己场上的「妮穆蕾莉娅」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把自己的额外卡组1张里侧表示的卡里侧表示除外。
function c18458255.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：从额外卡组把2张里侧表示的卡里侧表示除外才能发动。从卡组把2只卡名不同的兽族·10星怪兽加入手卡。这个效果发动的回合，自己不是灵摆怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,18458255)
	e1:SetCost(c18458255.cost)
	e1:SetTarget(c18458255.target)
	e1:SetOperation(c18458255.activate)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在该回合是否已经发动过①效果，防止重复使用。
	Duel.AddCustomActivityCounter(18458255,ACTIVITY_SPSUMMON,c18458255.counterfilter)
	-- ②：自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在，自己场上的「妮穆蕾莉娅」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把自己的额外卡组1张里侧表示的卡里侧表示除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c18458255.repcon)
	e2:SetTarget(c18458255.reptg)
	e2:SetValue(c18458255.repval)
	e2:SetOperation(c18458255.repop)
	c:RegisterEffect(e2)
end
-- 计数器过滤函数，用于判断是否满足限制条件（非额外召唤或灵摆怪兽不计入计数）。
function c18458255.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_PENDULUM)
end
-- 检索函数，用于筛选额外卡组中可以作为除外代价的里侧表示卡。
function c18458255.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
-- 效果发动时的处理函数，检查是否满足发动条件并执行除外操作。
function c18458255.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查该玩家在本回合是否已经发动过①效果。
	local check=Duel.GetCustomActivityCount(18458255,tp,ACTIVITY_SPSUMMON)==0
	-- 获取满足条件的额外卡组中的里侧表示卡组。
	local g=Duel.GetMatchingGroup(c18458255.rmfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>=2 and check end
	-- 创建并注册一个禁止特殊召唤的效果，用于限制发动①效果后本回合不能特殊召唤非灵摆怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c18458255.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将禁止特殊召唤的效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:Select(tp,2,2,nil)
	-- 将选中的卡以里侧表示形式除外作为发动代价。
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
end
-- 限制特殊召唤的过滤函数，禁止从额外卡组召唤非灵摆怪兽。
function c18458255.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_PENDULUM)
end
-- 检索函数，用于筛选卡组中满足条件的兽族·10星怪兽。
function c18458255.filter(c)
	return c:IsLevel(10) and c:IsRace(RACE_BEAST) and c:IsAbleToHand()
end
-- 效果的目标设定函数，检查是否有足够的满足条件的卡，并设置操作信息。
function c18458255.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的卡组中的兽族·10星怪兽。
	local g=Duel.GetMatchingGroup(c18458255.filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=2 end
	-- 设置操作信息，表示将要将2张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果的发动处理函数，选择并加入手牌。
function c18458255.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组中的兽族·10星怪兽。
	local g=Duel.GetMatchingGroup(c18458255.filter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的2张不同卡名的兽族·10星怪兽。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if not sg then return end
	-- 将选中的卡加入手牌。
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	-- 向对方确认加入手牌的卡。
	Duel.ConfirmCards(1-tp,sg)
end
-- 代替破坏时的检索函数，用于筛选额外卡组中可以作为除外代价的里侧表示卡。
function c18458255.reprmfilter(c,tp)
	return c:IsFacedown() and c:IsAbleToRemove(tp,POS_FACEDOWN,REASON_EFFECT)
end
-- 代替破坏时的条件函数，检查是否满足发动条件。
function c18458255.repcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查玩家额外卡组是否存在表侧表示的「梦见之妮穆蕾莉娅」。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_EXTRA,0,1,nil,70155677)
end
-- 代替破坏时的过滤函数，用于筛选场上被破坏的妮穆蕾莉娅怪兽。
function c18458255.repfilter(c,tp)
	return not c:IsReason(REASON_REPLACE) and c:IsFaceup()
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsSetCard(0x191)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
end
-- 代替破坏时的目标设定函数，检查是否满足发动条件。
function c18458255.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c18458255.repfilter,1,nil,tp)
		-- 检查玩家额外卡组中是否存在可以作为除外代价的卡。
		and Duel.IsExistingMatchingCard(c18458255.reprmfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 询问玩家是否发动代替破坏效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏时的值设定函数，返回是否满足代替破坏条件。
function c18458255.repval(e,c)
	return c18458255.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏时的处理函数，选择并除外一张卡。
function c18458255.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动代替破坏效果。
	Duel.Hint(HINT_CARD,0,18458255)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张额外卡组中的里侧表示卡。
	local g=Duel.SelectMatchingCard(tp,c18458255.reprmfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	-- 将选中的卡以里侧表示形式除外作为代替破坏的代价。
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT+REASON_REPLACE)
end
