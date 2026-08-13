--クシャトリラ・プリペア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合可以发动。从手卡的怪兽以及除外的自己怪兽之中选1只「俱舍怒威族」怪兽特殊召唤。
-- ②：这张卡已在魔法与陷阱区域存在的状态，对方把陷阱卡的效果发动的场合，若自己场上有「俱舍怒威族」怪兽存在则能发动。把对方手卡确认，选那之内的1张里侧表示除外。
function c21639276.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方回合可以发动。从手卡的怪兽以及除外的自己怪兽之中选1只「俱舍怒威族」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21639276,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,21639276)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetTarget(c21639276.sptg)
	e2:SetOperation(c21639276.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡已在魔法与陷阱区域存在的状态，对方把陷阱卡的效果发动的场合，若自己场上有「俱舍怒威族」怪兽存在则能发动。把对方手卡确认，选那之内的1张里侧表示除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21639276,1))  --"手卡除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,21639277)
	e3:SetCondition(c21639276.rmcon)
	e3:SetTarget(c21639276.rmtg)
	e3:SetOperation(c21639276.rmop)
	c:RegisterEffect(e3)
end
-- ①效果的候选怪兽过滤函数：要求卡名属于「俱舍怒威族」、能够被当前效果特殊召唤，并且位于手卡或是表侧表示的除外状态（里侧除外怪兽无法确认卡名，不能选择）。
function c21639276.spfilter(c,e,tp)
	return c:IsSetCard(0x189) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- ①效果发动条件判定：自己主要怪兽区域有空位，且手卡或除外的自己怪兽中存在满足spfilter条件的「俱舍怒威族」怪兽。
function c21639276.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区域是否有可用的空位，没有空位则无法发动①效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查以自己视角看，在手卡和除外区是否存在至少1只满足spfilter条件的「俱舍怒威族」怪兽。
		and Duel.IsExistingMatchingCard(c21639276.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向对方玩家提示自己发动了①效果，显示效果描述，让对方知道发动的是哪个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置本次处理的操作信息：效果分类包含特殊召唤，预计从手卡和除外区将1只怪兽特殊召唤到自己场上（对象在处理时才确定，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end
-- ①效果处理：如果仍有空位，则从手卡和除外区选择1只符合条件的「俱舍怒威族」怪兽以表侧表示特殊召唤到自己场上。
function c21639276.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区域有空位，若没有空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择框，提示自己选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡和除外的自己怪兽中选取1只满足spfilter条件的「俱舍怒威族」怪兽。
	local g=Duel.SelectMatchingCard(tp,c21639276.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上，进行检查召唤条件和苏生限制的常规特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的辅助过滤函数：判断自己场上的怪兽是否为表侧表示的「俱舍怒威族」怪兽。
function c21639276.rmcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x189)
end
-- ②效果的发动条件：对方发动陷阱卡效果、此卡在魔陷区效果有效，并且自己场上有表侧表示「俱舍怒威族」怪兽存在。
function c21639276.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_TRAP) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
		-- 检查自己场上是否存在至少1只表侧表示的「俱舍怒威族」怪兽，满足②效果发动的场上有怪兽条件。
		and Duel.IsExistingMatchingCard(c21639276.rmcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标与发动信息设置：先确认对方手卡中有可除外的卡，满足后向对方提示发动②效果，并设置除外操作信息。
function c21639276.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡是否存在至少1张可以被里侧表示除外（允许除外）的卡，作为②效果发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,tp,POS_FACEDOWN) end
	-- 向对方玩家提示自己发动了②效果，显示效果描述，让对方知道发动的是哪个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置本次处理的操作信息：效果分类包含除外，预计从对方手卡除外1张卡（目标在处理时才选择，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
-- ②效果处理：确认对方手卡，从中选择1张里侧表示除外，最后洗切对方手卡。
function c21639276.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方所有手卡，作为确认和选择的对象集合。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 向自己展示对方所有手卡，使下一步选择可见。
	Duel.ConfirmCards(tp,g)
	-- 弹出选择框，提示自己选择要里侧表示除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil,tp,POS_FACEDOWN)
	if #sg>0 then
		-- 将选择的1张卡以里侧表示除外，原因为效果。
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	end
	-- 对方手卡经过确认和除外后需要洗切，恢复牌堆随机性。
	Duel.ShuffleHand(1-tp)
end
