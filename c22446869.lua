--水精鱗－ディニクアビス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从手卡把这张卡以外的1只水属性怪兽丢弃去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的①的效果特殊召唤成功时才能发动。从卡组把1只4星以下的「水精鳞」怪兽加入手卡。
function c22446869.initial_effect(c)
	-- ①：从手卡把这张卡以外的1只水属性怪兽丢弃去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22446869,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c22446869.spcost)
	e1:SetTarget(c22446869.sptg)
	e1:SetOperation(c22446869.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡的①的效果特殊召唤成功时才能发动。从卡组把1只4星以下的「水精鳞」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22446869,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,22446869)
	e2:SetCondition(c22446869.thcon)
	e2:SetTarget(c22446869.thtg)
	e2:SetOperation(c22446869.thop)
	c:RegisterEffect(e2)
end
-- 筛选可作为①效果发动代价的水属性手卡怪兽：需为水属性、可作为代价丢弃且可送去墓地。
function c22446869.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- ①效果的代价处理：先检查手卡中是否存在满足条件的‘这张卡以外’的水属性怪兽，然后丢弃1张作为发动代价。
function c22446869.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查手卡中是否存在满足 cfilter 的‘这张卡以外’的水属性怪兽，且可以作为代价丢弃。
	if chk==0 then return Duel.IsExistingMatchingCard(c22446869.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让发动者从手卡选择1张满足条件的水属性怪兽丢弃去墓地，作为①效果发动的代价。
	Duel.DiscardHand(tp,c22446869.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- ①效果发动目标确认：检查我方主要怪兽区是否有空位，以及这张卡自身能否被特殊召唤。
function c22446869.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方场上是否存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁处理信息标记为特殊召唤这张卡1张，供后续时点检测等使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将自身特殊召唤到场上。
function c22446869.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以自身效果方式将这张卡表侧表示特殊召唤到我方场上。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- ②效果发动条件：此卡是通过①效果（自身效果）特殊召唤成功的场合才能发动。
function c22446869.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 检索过滤：卡名带有「水精鳞」字段、等级4以下且可以加入手卡的怪兽。
function c22446869.thfilter(c)
	return c:IsSetCard(0x74) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- ②效果发动目标：检查卡组中存在符合条件的水精鳞怪兽，并设置检索加入手卡的操作信息。
function c22446869.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在满足 thfilter 的检索对象。
	if chk==0 then return Duel.IsExistingMatchingCard(c22446869.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：不取对象地从卡组把1张符合条件的卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只符合条件的「水精鳞」怪兽加入手卡，并向对方确认。
function c22446869.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足 thfilter 的「水精鳞」怪兽。
	local g=Duel.SelectMatchingCard(tp,c22446869.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
