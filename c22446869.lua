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
	-- ②：这张卡的①的效果特殊召唤成功时才能发动。从卡组把1只4星以下的「水精鳞」怪兽加入手卡。
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
-- 过滤函数，用于判断手卡中是否包含满足条件的水属性怪兽（可丢弃且能送入墓地）
function c22446869.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 检查手卡中是否存在满足条件的水属性怪兽并将其丢弃作为特殊召唤的代价
function c22446869.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c22446869.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡丢弃1只满足条件的水属性怪兽
	Duel.DiscardHand(tp,c22446869.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 判断特殊召唤是否可以发动（场地是否足够且该卡是否能被特殊召唤）
function c22446869.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将该卡特殊召唤到场上
function c22446869.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡以正面表示形式特殊召唤到场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 判断该卡是否为通过①效果特殊召唤成功
function c22446869.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤函数，用于检索卡组中满足条件的4星以下的「水精鳞」怪兽
function c22446869.thfilter(c)
	return c:IsSetCard(0x74) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 判断检索效果是否可以发动（卡组中是否存在满足条件的怪兽）
function c22446869.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「水精鳞」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c22446869.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，从卡组选择1只满足条件的怪兽加入手牌
function c22446869.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c22446869.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选怪兽的卡面
		Duel.ConfirmCards(1-tp,g)
	end
end
