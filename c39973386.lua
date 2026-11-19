--表裏一体
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只光·暗属性怪兽解放才能发动。和那只怪兽是原本的种族·等级相同而原本属性不同的1只光·暗属性怪兽从手卡·额外卡组特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地的光·暗属性怪兽各1只为对象才能发动。那2只怪兽回到卡组洗切。那之后，自己从卡组抽1张。
function c39973386.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把自己场上1只光·暗属性怪兽解放才能发动。和那只怪兽是原本的种族·等级相同而原本属性不同的1只光·暗属性怪兽从手卡·额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,39973386)
	e1:SetTarget(c39973386.target)
	e1:SetOperation(c39973386.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己主要阶段把墓地的这张卡除外，以自己墓地的光·暗属性怪兽各1只为对象才能发动。那2只怪兽回到卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,39973387)
	-- 设置②效果的发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c39973386.tdtg)
	e2:SetOperation(c39973386.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为可解放的光·暗属性且原本等级大于0，并且手卡或额外卡组存在可作为特召目标的对应怪兽。
function c39973386.costfilter(c,e,tp)
	return (c:IsControler(tp) or c:IsFaceup())
		and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:GetOriginalLevel()>0
		-- 检查自己手卡或额外卡组中是否存在至少1只满足对应条件的待特殊召唤怪兽。
		and Duel.IsExistingMatchingCard(c39973386.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,c,e,tp)
end
-- 过滤函数：判断手卡或额外卡组的怪兽是否原本属性与解放怪兽不同、为光·暗属性且原本种族与原本等级相同、能特殊召唤并有足够出场空位。
function c39973386.spfilter(c,tc,e,tp)
	if c:GetOriginalAttribute()==tc:GetOriginalAttribute() then return end
	-- 判断该怪兽是否位于手卡且解放目标怪兽后自己主要怪兽区有空位。
	local b1=c:IsLocation(LOCATION_HAND) and Duel.GetMZoneCount(tp,tc)>0
	-- 判断该怪兽是否位于额外卡组且解放目标怪兽离场后自己场上有可从额外卡组特召该怪兽的空位。
	local b2=c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and c:GetOriginalLevel()==tc:GetOriginalLevel()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (b1 or b2)
end
-- ①效果的目标处理函数（可行性检测部分）：检查代价状态已确认且场上存在符合解放条件的光·暗属性怪兽。
function c39973386.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 且检查自己场上是否存在至少1只满足条件的怪兽可供解放。
		and Duel.CheckReleaseGroup(tp,c39973386.costfilter,1,nil,e,tp) end
	-- 让玩家从自己场上选择1只符合条件的光·暗属性怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c39973386.costfilter,1,1,nil,e,tp)
	-- 将选中的怪兽作为发动代价解放。
	Duel.Release(g,REASON_COST)
	-- 将被解放的怪兽记录为连锁对象信息，供效果处理时读取其原本种族、等级和属性。
	Duel.SetTargetCard(g)
	-- 设置操作信息：预计从自己的手卡或额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
end
-- ①效果的效果处理函数：根据解放怪兽的信息，从手卡或额外卡组选择1只满足条件的怪兽特殊召唤到自己场上。
function c39973386.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前作为代价解放并记录下来的怪兽卡。
	local tc=Duel.GetFirstTarget()
	-- 向自己发送选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡或额外卡组中选择1只满足条件的光·暗属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c39973386.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,tc,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：判断卡片是否为光属性或暗属性怪兽、能否返回卡组且能否成为本效果的对象。
function c39973386.tdfilter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToDeck()
end
-- ②效果的对象选择与目标处理函数：从自己墓地选择光属性和暗属性怪兽各1只作为对象，并申报回卡组和抽1张卡的操作信息。
function c39973386.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39973386.tdfilter(chkc,e) end
	-- 获取自己墓地中所有符合返回卡组和取对象条件的光·暗属性怪兽卡片组。
	local g=Duel.GetMatchingGroup(c39973386.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- 发动可行性检测：检查能否从候选怪兽中选出属性不同的2只（光与暗各1只），且自己能抽1张卡。
	if chk==0 then return g:CheckSubGroup(aux.dabcheck,2,2) and Duel.IsPlayerCanDraw(tp,1) end
	-- 向自己发送选择提示，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地的候选怪兽中选择属性不同的2只怪兽（即光属性与暗属性各1只）。
	local sg=g:SelectSubGroup(tp,aux.dabcheck,false,2,2)
	-- 将选中的2只怪兽设为当前连锁的效果对象。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：预计将选中的2只怪兽返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,2,0,0)
	-- 设置操作信息：预计由自己玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的效果处理函数：若2只对象怪兽仍都与效果有联系，则将它们返回卡组洗切，并中断效果后使自己抽1张卡。
function c39973386.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁指定的所有对象卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=2 then return end
	-- 将2只目标怪兽以效果返回各自持有者的卡组或额外卡组并标记洗牌。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际被送回卡组或额外卡组的卡片组。
	local g=Duel.GetOperatedGroup()
	-- 若实际操作的卡中有回到主卡组的卡，则洗切自己的卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==2 then
		-- 中断当前效果处理，使之后的抽卡与前面的回卡组洗切处理视为不同时进行。
		Duel.BreakEffect()
		-- 使自己以效果从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
