--恐巄竜華－㟴巴
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：让这张卡从手卡回到卡组才能发动。从卡组把1张「登龙华恐巃门」加入手卡。
-- ②：2张以上的卡被破坏的回合的自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤。
-- ③：让自己场上1张表侧表示的「登龙华恐巃门」回到卡组最下面，以最多有场上的种族种类数量的场上的其他卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含效果①、效果②、效果③以及用于记录卡片破坏数量的全局监听器。
function s.initial_effect(c)
	-- 注册该卡片效果中记载了「登龙华恐巃门」（卡号82661630）的卡名。
	aux.AddCodeList(c,82661630)
	-- ①：让这张卡从手卡回到卡组才能发动。从卡组把1张「登龙华恐巃门」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：2张以上的卡被破坏的回合的自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：让自己场上1张表侧表示的「登龙华恐巃门」回到卡组最下面，以最多有场上的种族种类数量的场上的其他卡为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"卡片破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		-- 这个卡名的①②③的效果1回合各能使用1次。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(s.checkop)
		-- 在全局环境注册该全局监听效果。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 破坏事件发生时的全局检查操作，用于记录本回合被破坏的卡片数量。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历当前被破坏的卡片组。
	for tc in aux.Next(eg) do
		-- 为自己注册一个持续到回合结束的标识效果，用于累计被破坏的卡片数量。
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		-- 为对方注册一个持续到回合结束的标识效果，用于累计被破坏的卡片数量。
		Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 效果①的启动费用（Cost）函数，检查并执行将自身从手卡送回卡组。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 作为发动费用，将手卡的这张卡送回卡组并洗牌。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 效果①的检索过滤条件：卡名为「登龙华恐巃门」且能加入手卡。
function s.thfilter(c)
	return c:IsCode(82661630) and c:IsAbleToHand()
end
-- 效果①的发动准备（Target）函数，检查卡组是否存在目标卡并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查卡组中是否存在至少1张满足过滤条件的「登龙华恐巃门」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示将从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）函数，执行检索「登龙华恐巃门」的操作。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「登龙华恐巃门」。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g then
		-- 将选择的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件（Condition）函数，检查本回合是否有2张以上的卡被破坏，且当前处于双方的主要阶段。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查被破坏卡片的累计标识数量是否达到2个以上，且当前阶段为主要阶段1或主要阶段2。
	return Duel.GetFlagEffect(tp,id)>=2 and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果②的发动准备（Target）函数，检查怪兽区域空格并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上怪兽区域是否有空位，且手卡的这张卡是否可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表示将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理（Operation）函数，执行特殊召唤自身的操作。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到发动效果玩家的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的费用过滤条件：自己场上表侧表示的「登龙华恐巃门」，且能回到卡组，并且场上还存在其他可以作为破坏对象的卡。
function s.costfilter(c,tp,ec)
	return c:IsFaceup() and c:IsCode(82661630) and c:IsAbleToDeckAsCost()
		-- 检查场上是否存在除作为费用的卡和自身以外的至少1张卡，以确保有合法的破坏对象。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,ec))
end
-- 效果③的启动费用（Cost）函数，执行将自己场上表侧表示的「登龙华恐巃门」送回卡组最底下的操作。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否存在满足费用过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,c) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己场上1张满足条件的「登龙华恐巃门」。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp,c)
	-- 选中该卡并显示被选为费用的动画效果。
	Duel.HintSelection(g)
	-- 作为发动费用，将选择的卡送回持有者卡组最下面。
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 统计种族数量的过滤条件：场上表侧表示的怪兽。
function s.cfilter(c)
	return c:IsFaceup()
end
-- 效果③的发动准备（Target）函数，计算场上种族种类数量，并选择对应数量的场上其他卡作为对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 获取双方场上所有表侧表示的怪兽。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local gc=g:GetClassCount(Card.GetRace)
	if chkc then return chkc:IsOnField() and chkc~=c end
	-- 检查场上是否存在种族，且场上存在至少1张除自身以外的其他卡可以作为破坏对象。
	if chk==0 then return gc>0 and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多有场上种族种类数量的场上其他卡作为效果对象。
	local sg=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,gc,c)
	-- 设置连锁处理的操作信息，表示将破坏选中的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果③的效果处理（Operation）函数，执行破坏作为对象卡片的操作。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果有关联的对象卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 破坏这些对象卡。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
