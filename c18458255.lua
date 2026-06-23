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
	-- 添加自定义活动计数器，用于检测该回合是否从额外卡组特殊召唤过表侧表示灵摆怪兽以外的怪兽
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
-- 过滤条件：非从额外卡组特殊召唤，或者是从额外卡组特殊召唤的表侧表示灵摆怪兽
function c18458255.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
-- 过滤条件：额外卡组里侧表示且能作为cost里侧表示除外的卡
function c18458255.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
-- ①效果的发动代价与限制：检查特殊召唤限制，从额外卡组将2张里侧表示的卡里侧表示除外，并适用限制效果
function c18458255.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否未进行过不满足过滤条件的特殊召唤（即是否未从额外卡组特殊召唤过表侧表示灵摆怪兽以外的怪兽）
	local check=Duel.GetCustomActivityCount(18458255,tp,ACTIVITY_SPSUMMON)==0
	-- 获取自己额外卡组所有里侧表示且可以除外的卡片
	local g=Duel.GetMatchingGroup(c18458255.rmfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>=2 and check end
	-- ①：从额外卡组把2张里侧表示的卡里侧表示除外才能发动。从卡组把2只卡名不同的兽族·10星怪兽加入手卡。这个效果发动的回合，自己不是灵摆怪兽不能从额外卡组特殊召唤。/②：自己的额外卡组有表侧表示的「梦见之妮穆蕾莉娅」存在，自己场上的「妮穆蕾莉娅」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把自己的额外卡组1张里侧表示的卡里侧表示除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c18458255.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在自己玩家身上注册该回合不能从额外卡组特殊召唤灵摆怪兽以外的怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
	-- 给玩家提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:Select(tp,2,2,nil)
	-- 作为发动代价将所选择的卡片里侧表示除外
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
end
-- 限制条件：不能从额外卡组特殊召唤灵摆怪兽以外的怪兽
function c18458255.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_PENDULUM)
end
-- 过滤条件：卡组中等级10的兽族怪兽且能加入手牌
function c18458255.filter(c)
	return c:IsLevel(10) and c:IsRace(RACE_BEAST) and c:IsAbleToHand()
end
-- ①效果的靶向：检查卡组中是否存在至少2张卡名不同的等级10兽族怪兽，并设置加入手牌的操作信息
function c18458255.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组中所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(c18458255.filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=2 end
	-- 设置效果处理信息为从卡组将2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- ①效果的执行：从卡组选择2只卡名不同的等级10兽族怪兽加入手牌并给对方确认
function c18458255.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(c18458255.filter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	-- 给玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从符合条件的怪兽中选择2只卡名不同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if not sg then return end
	-- 将选择的怪兽加入手牌
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	-- 给对方玩家确认加入手牌的卡片
	Duel.ConfirmCards(1-tp,sg)
end
-- 过滤条件：额外卡组里侧表示且可以被效果除外的卡
function c18458255.reprmfilter(c,tp)
	return c:IsFacedown() and c:IsAbleToRemove(tp,POS_FACEDOWN,REASON_EFFECT)
end
-- 代替破坏的条件：自己额外卡组存在表侧表示的「梦见之妮穆蕾莉娅」
function c18458255.repcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查额外卡组是否存在表侧表示的「梦见之妮穆蕾莉娅」
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_EXTRA,0,1,nil,70155677)
end
-- 过滤条件：自己场上被战斗或者对方效果破坏的表侧表示「妮穆蕾莉娅」怪兽
function c18458255.repfilter(c,tp)
	return not c:IsReason(REASON_REPLACE) and c:IsFaceup()
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsSetCard(0x191)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
end
-- 代替破坏的靶向：检查是否有符合代替破坏条件的怪兽被破坏，且额外卡组有里侧表示的卡可以除外
function c18458255.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c18458255.repfilter,1,nil,tp)
		-- 并检查自己额外卡组是否存在能以效果除外的里侧表示卡片
		and Duel.IsExistingMatchingCard(c18458255.reprmfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 让玩家选择是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的值过滤：确定需要代替破坏的怪兽是否符合条件
function c18458255.repval(e,c)
	return c18458255.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的执行：选择自己额外卡组的1张里侧表示卡片里侧表示除外以代替破坏
function c18458255.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 手动显示卡片发动的提示
	Duel.Hint(HINT_CARD,0,18458255)
	-- 给玩家提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己额外卡组1张里侧表示卡片
	local g=Duel.SelectMatchingCard(tp,c18458255.reprmfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	-- 将选择的卡片作为代替破坏里侧表示除外
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT+REASON_REPLACE)
end
