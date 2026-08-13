--天空神騎士ロードパーシアス
-- 效果：
-- 天使族怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。把1张「天空的圣域」或者有那个卡名记述的卡从卡组加入手卡。场上有「天空的圣域」存在的场合，可以把加入手卡的卡改成1只天使族怪兽。
-- ②：自己场上的表侧表示的天使族怪兽被送去墓地的场合，从自己墓地把1只天使族怪兽除外才能发动。比除外的怪兽等级高的1只天使族怪兽从手卡特殊召唤。
function c48589580.initial_effect(c)
	-- 将「天空的圣域」(56433456)记录为这张卡文本中记述的卡名，使后续可通过aux.IsCodeOrListed判断“有那个卡名记述的卡”。
	aux.AddCodeList(c,56433456)
	c:EnableReviveLimit()
	-- 为这张卡设置连接召唤手续：用2只以上天使族怪兽作为连接素材，对应召唤条件“天使族怪兽2只以上”。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_FAIRY),2)
	-- ①：丢弃1张手卡才能发动。把1张「天空的圣域」或者有那个卡名记述的卡从卡组加入手卡。场上有「天空的圣域」存在的场合，可以把加入手卡的卡改成1只天使族怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48589580,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,48589580)
	e1:SetCost(c48589580.thcost)
	e1:SetTarget(c48589580.thtg)
	e1:SetOperation(c48589580.thop)
	c:RegisterEffect(e1)
	-- ②：自己场上的表侧表示的天使族怪兽被送去墓地的场合，从自己墓地把1只天使族怪兽除外才能发动。比除外的怪兽等级高的1只天使族怪兽从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48589580,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,48589581)
	e2:SetCondition(c48589580.spcon)
	e2:SetCost(c48589580.spcost)
	e2:SetTarget(c48589580.sptg)
	e2:SetOperation(c48589580.spop)
	c:RegisterEffect(e2)
end
-- ①效果的代价函数：判定并执行丢弃1张手卡作为发动代价。
function c48589580.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查时，确认手牌存在至少1张可丢弃的卡，以保证能支付丢弃1张手卡的费用。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择1张手卡丢弃，作为发动代价（REASON_COST+REASON_DISCARD）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ①效果的检索过滤函数：检索对象为「天空的圣域」或记述了该卡名的卡；若场上有「天空的圣域」，也可选择天使族怪兽，且这些卡都能加入手卡。
function c48589580.thfilter(c,thchk)
	-- 返回过滤条件：满足“是「天空的圣域」或记述其卡名的卡”，或“场上有「天空的圣域」且是天使族怪兽”，并且该卡能够加入手卡。
	return (aux.IsCodeOrListed(c,56433456) or thchk and c:IsRace(RACE_FAIRY)) and c:IsAbleToHand()
end
-- ①效果的目标函数：根据场上是否有「天空的圣域」判定能否检索对应卡牌，并设置本次操作的信息为从卡组检索1张加入手卡。
function c48589580.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前环境是否存在「天空的圣域」，结果存入thchk，用于决定是否允许检索天使族怪兽。
	local thchk=Duel.IsEnvironment(56433456)
	-- 合法性检查时，确认卡组中存在至少1张满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c48589580.thfilter,tp,LOCATION_DECK,0,1,nil,thchk) end
	-- 设置操作信息：本次效果处理涉及从卡组将1张卡加入手卡（CATEGORY_TOHAND），目标位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理函数：从卡组选择1张符合条件的卡加入手卡，并让对方确认。
function c48589580.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查当前环境是否存在「天空的圣域」，以决定可选范围。
	local thchk=Duel.IsEnvironment(56433456)
	-- 弹出选择提示，让玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,c48589580.thfilter,tp,LOCATION_DECK,0,1,1,nil,thchk)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认被检索加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 触发条件过滤函数：判断送去墓地的怪兽是否是自己场上表侧表示的天使族怪兽（要求离场前在场上的种族和当前种族均为天使族，且控制者是自己、位置是主要怪兽区、表示形式为表侧）。
function c48589580.cfilter(c,tp)
	return bit.band(c:GetPreviousRaceOnField(),RACE_FAIRY)~=0 and c:IsRace(RACE_FAIRY)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- ②的触发条件：存在至少1只符合条件的、自己场上的表侧天使族怪兽被送去墓地。
function c48589580.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c48589580.cfilter,1,nil,tp)
end
-- ②的代价函数：先设置标记(label=100)，表示需要进入目标处理阶段选择并除外墓地的天使族怪兽；实际除外操作在sptg中完成。
function c48589580.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 筛选可作为②代价的墓地天使族怪兽：需为天使族且等级大于0，并且手牌中存在等级比它高的天使族怪兽可供特殊召唤。
function c48589580.costfilter(c,e,tp)
	local lv=c:GetLevel()
	-- 返回过滤条件：该墓地怪兽是天使族、等级>0，且手牌中存在等级高于它的可特殊召唤天使族怪兽。
	return lv>0 and c:IsRace(RACE_FAIRY) and Duel.IsExistingMatchingCard(c48589580.spfilter,tp,LOCATION_HAND,0,1,nil,lv+1,e,tp)
end
-- 筛选可从手卡特殊召唤的天使族怪兽：等级高于除外怪兽（传入lv+1即需大于除外的等级），种族为天使族，且满足特殊召唤限制。
function c48589580.spfilter(c,lv,e,tp)
	return c:IsLevelAbove(lv) and c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的目标处理：选择并除外1只墓地天使族怪兽作为代价，记录其等级；设置操作信息为从手卡特殊召唤1只天使族怪兽。
function c48589580.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 确认自己的主要怪兽区域有空位，用于后续特殊召唤。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 确认墓地存在可作为代价且能保证手牌有可特殊召唤怪兽的1只天使族怪兽。
			and Duel.IsExistingMatchingCard(c48589580.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 弹出选择提示，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从墓地选择1只满足条件的天使族怪兽作为除外代价。
	local rg=Duel.SelectMatchingCard(tp,c48589580.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 将选中的墓地天使族怪兽正面表示除外，作为发动代价。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	-- 设置操作信息：本次效果处理包含从手卡特殊召唤1只怪兽（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②的效果处理函数：从手卡选择1只等级高于已除外怪兽的天使族怪兽，表侧表示特殊召唤到自己场上。
function c48589580.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 特殊召唤处理前检查主要怪兽区是否有空位，没有空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 弹出选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只等级高于已除外怪兽等级的天使族怪兽。
	local g=Duel.SelectMatchingCard(tp,c48589580.spfilter,tp,LOCATION_HAND,0,1,1,nil,lv+1,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
