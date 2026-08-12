--三幻魔の神淵
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。从自己的手卡·卡组·墓地把2张「三幻魔的神渊」在自己场上表侧表示放置。
-- ②：把包含这张卡的自己场上3张表侧表示的「三幻魔的神渊」送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ③：这张卡在墓地存在的场合，对方结束阶段才能发动。这张卡回到卡组最下面。
local s,id,o=GetID()
-- 初始化卡片效果，注册永续魔法卡的卡片发动效果、效果①的表侧放置、效果②的里侧表示改变效果，以及效果③的墓地回到卡组效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的主要阶段才能发动。从自己的手卡·卡组·墓地把2张「三幻魔的神渊」在自己场上表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"表侧表示放置"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ②：把包含这张卡的自己场上3张表侧表示的「三幻魔的神渊」送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"变成里侧守备表示"
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(s.poscost)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在的场合，对方结束阶段才能发动。这张卡回到卡组最下面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"回到卡组"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.tdcon)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件：当前处于自己或对方的主要阶段。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 效果①中可以放置的卡片过滤条件：「三幻魔的神渊」且不受放置限制。
function s.tffilter(c,tp)
	return c:IsCode(id)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果①的发动可行性判定：魔陷区拥有至少两个空位，且手牌、卡组、墓地存在至少两张可放置的本卡同名卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果①判定的一部分：检查己方魔法与陷阱区域是否拥有2个以上的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 效果①判定的一部分：检查手牌、卡组、墓地中是否存在至少两张可以表侧表示放置到场上的「三幻魔的神渊」。
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,2,nil,tp) end
end
-- 效果①的执行操作：从手牌、卡组、墓地中选择2张「三幻魔的神渊」放置到场上，并考虑王家长眠之谷的过滤限制。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时判定：检查己方魔法与陷阱区域是否拥有至少2个空位，若不足则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=1 then return end
	-- 从手牌、卡组、墓地中获取所有不受王家长眠之谷影响且可放置的「三幻魔的神渊」集合。
	local pg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tffilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
	if pg:GetCount()<2 then return end
	local g=pg
	if pg:GetCount()>2 then
		-- 提示玩家选择要放置的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		g=pg:Select(tp,2,2,nil)
	end
	-- 遍历选出的要放置的卡片组进行逐一放置。
	for tc in aux.Next(g) do
		-- 将选择的卡片表侧表示放置在己方的魔法与陷阱区域。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
-- 效果②的Cost（代价）过滤条件：过滤场上表侧表示的、能作为Cost送去墓地的本名卡。
function s.costfilter(c)
	return c:IsFaceup() and c:IsCode(id) and c:IsAbleToGraveAsCost()
end
-- 效果②的Cost（代价）处理：把包含本卡在内的己方场上3张表侧表示的「三幻魔的神渊」送去墓地。
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果②的发动代价可行性检查的一部分：检查除这张卡以外，场上是否还存在至少2张表侧表示且能送去墓地的「三幻魔的神渊」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,2,e:GetHandler())
		and s.costfilter(c) end
	-- 提示玩家选择要作为代价送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择除本卡以外的2张符合条件的「三幻魔的神渊」作为连锁发动的代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,2,2,e:GetHandler())
	g:AddCard(c)
	-- 把选定的卡片以及本卡送去墓地作为效果发动的代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②中表示形式变更的目标过滤条件：过滤对方场上表侧表示且可以变成里侧表示的怪兽。
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果②的靶向/目标选择与发动判定：需要对方场上有可以变成里侧守备表示的表侧表示怪兽，发动时选择1只作为连锁对象，并注册改变表示形式的操作信息。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	-- 效果②的发动判定：检查对方场上是否存在可以变成里侧守备表示的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的对方表侧表示怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只符合条件的表侧表示怪兽作为对象。
	local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果②处理时的操作信息：预计将选中的怪兽改变表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果②的执行操作：将被选择为对象的怪兽变成里侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 将作为对象的怪兽变成里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 效果③的发动条件：当前回合是对方的回合且处于结束阶段。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否是对方。
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果③的发动可行性判定与操作信息注册：检查墓地的这张卡是否能回到卡组，并注册操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() end
	-- 设置效果③处理时的操作信息：预计将这张卡回到卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 效果③的执行操作：在不受王家长眠之谷影响的场合下，将墓地的这张卡送回卡组最下面。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时判定：检查这张卡是否仍与连锁相关，以及是否不受王家长眠之谷的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡送回卡组的最下面。
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
