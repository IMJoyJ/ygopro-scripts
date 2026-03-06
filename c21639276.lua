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
-- 过滤函数，用于筛选满足条件的「俱舍怒威族」怪兽，包括手卡和除外区的怪兽，且可以特殊召唤。
function c21639276.spfilter(c,e,tp)
	return c:IsSetCard(0x189) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 特殊召唤效果的发动条件判断，检查是否有满足条件的怪兽可特殊召唤。
function c21639276.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡或除外区是否存在满足条件的「俱舍怒威族」怪兽。
		and Duel.IsExistingMatchingCard(c21639276.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向对方玩家提示发动了特殊召唤效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤效果的操作信息，用于连锁处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end
-- 特殊召唤效果的处理函数，选择并特殊召唤符合条件的怪兽。
function c21639276.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或除外区选择满足条件的「俱舍怒威族」怪兽。
	local g=Duel.SelectMatchingCard(tp,c21639276.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选场上正面表示的「俱舍怒威族」怪兽。
function c21639276.rmcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x189)
end
-- 除外效果的发动条件判断，检查是否满足发动条件。
function c21639276.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_TRAP) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
		-- 检查玩家场上是否存在正面表示的「俱舍怒威族」怪兽。
		and Duel.IsExistingMatchingCard(c21639276.rmcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 除外效果的发动条件判断，检查是否有满足条件的卡可除外。
function c21639276.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡中是否存在可除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,tp,POS_FACEDOWN) end
	-- 向对方玩家提示发动了除外效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置除外效果的操作信息，用于连锁处理。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
-- 除外效果的处理函数，确认对方手卡并选择一张除外。
function c21639276.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡的全部卡片。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 确认对方手卡中的所有卡片。
	Duel.ConfirmCards(tp,g)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil,tp,POS_FACEDOWN)
	if #sg>0 then
		-- 将选中的卡以里侧表示形式除外。
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	end
	-- 将对方手卡洗牌。
	Duel.ShuffleHand(1-tp)
end
