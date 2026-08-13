--表裏一体
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只光·暗属性怪兽解放才能发动。和那只怪兽是原本的种族·等级相同而原本属性不同的1只光·暗属性怪兽从手卡·额外卡组特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地的光·暗属性怪兽各1只为对象才能发动。那2只怪兽回到卡组洗切。那之后，自己从卡组抽1张。
function c39973386.initial_effect(c)
	-- ①：把自己场上1只光·暗属性怪兽解放才能发动。和那只怪兽是原本的种族·等级相同而原本属性不同的1只光·暗属性怪兽从手卡·额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,39973386)
	e1:SetTarget(c39973386.target)
	e1:SetOperation(c39973386.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地的光·暗属性怪兽各1只为对象才能发动。那2只怪兽回到卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,39973387)
	-- 设置②效果的发动代价为“把墓地的这张卡除外”，使用aux.bfgcost作为代价处理函数。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c39973386.tdtg)
	e2:SetOperation(c39973386.tdop)
	c:RegisterEffect(e2)
end
-- 定义①效果的解放代价筛选函数：要求可解放的怪兽是光·暗属性且原本等级大于0，并确认存在可特殊召唤的候选怪兽。
function c39973386.costfilter(c,e,tp)
	return (c:IsControler(tp) or c:IsFaceup())
		and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:GetOriginalLevel()>0
		-- 检查是否存在至少1只满足spfilter条件的光·暗属性怪兽可以从手卡·额外卡组特殊召唤，用于确保代价怪兽值得解放。
		and Duel.IsExistingMatchingCard(c39973386.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,c,e,tp)
end
-- 定义特殊召唤候选怪兽的筛选条件：必须是光·暗属性，与被解放怪兽原本种族·等级相同但原本属性不同，且能够被特殊召唤并有可用区域。
function c39973386.spfilter(c,tc,e,tp)
	if c:GetOriginalAttribute()==tc:GetOriginalAttribute() then return end
	-- 判断候选怪兽若在手牌时，解放代价怪兽后自己场上是否有空余的怪兽区可供特殊召唤。
	local b1=c:IsLocation(LOCATION_HAND) and Duel.GetMZoneCount(tp,tc)>0
	-- 判断候选怪兽若在额外卡组时，解放代价怪兽后是否有足够的额外卡组怪兽可用区域可供特殊召唤。
	local b2=c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and c:GetOriginalLevel()==tc:GetOriginalLevel()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (b1 or b2)
end
-- ①效果发动条件判定：确认代价已满足，且场上存在可解放的合适光·暗属性怪兽。
function c39973386.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在至少1只满足costfilter条件的可解放怪兽作为发动代价。
		and Duel.CheckReleaseGroup(tp,c39973386.costfilter,1,nil,e,tp) end
	-- 选择1只满足解放条件的怪兽作为①效果的发动代价。
	local g=Duel.SelectReleaseGroup(tp,c39973386.costfilter,1,1,nil,e,tp)
	-- 将选择的怪兽解放，作为①效果的发动代价。
	Duel.Release(g,REASON_COST)
	-- 将解放的怪兽设为效果对象，供特殊召唤时参照其原本种族·等级和属性。
	Duel.SetTargetCard(g)
	-- 设置操作信息：本次效果将从手卡·额外卡组特殊召唤1只怪兽，具体卡片在效果处理时选择确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
end
-- ①效果处理：选择1只符合条件的怪兽并从手卡·额外卡组特殊召唤。
function c39973386.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为①效果对象的被解放怪兽，用于筛选特殊召唤候选。
	local tc=Duel.GetFirstTarget()
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·额外卡组中选择1只满足spfilter条件的怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c39973386.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,tc,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果回卡组对象的筛选条件：可作为效果对象、光·暗属性且能够回到卡组。
function c39973386.tdfilter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToDeck()
end
-- ②效果发动处理：从墓地选择2只属性不同的光·暗属性怪兽作为对象，并设置回卡组和抽卡的操作信息。
function c39973386.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39973386.tdfilter(chkc) end
	-- 获取自己墓地中所有满足回卡组条件的怪兽集合。
	local g=Duel.GetMatchingGroup(c39973386.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- 判定墓地中是否存在2只属性不同的可选怪兽，且自己可以抽1张卡。
	if chk==0 then return g:CheckSubGroup(aux.dabcheck,2,2) and Duel.IsPlayerCanDraw(tp,1) end
	-- 向玩家显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从符合条件的墓地怪兽中选择2只属性不同的怪兽作为②效果的对象。
	local sg=g:SelectSubGroup(tp,aux.dabcheck,false,2,2)
	-- 将选择的2只怪兽设为效果对象。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：将对象卡片返回卡组，数量为2张。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,2,0,0)
	-- 设置操作信息：接下来自己从卡组抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：将对象怪兽送回卡组洗切，若2只均成功回到卡组或额外卡组，则自己抽1张。
function c39973386.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁处理时记录的②效果对象怪兽。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=2 then return end
	-- 将对象怪兽送回持有者卡组并洗切。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被送回卡组的卡片组。
	local g=Duel.GetOperatedGroup()
	-- 如果有卡片回到了卡组，则洗切该卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==2 then
		-- 中断当前效果处理，使回卡组和抽卡视为不同时点处理，避免错误触发时点。
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
