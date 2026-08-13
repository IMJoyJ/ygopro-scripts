--スプリガンズ・キット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：需以「阿不思的落胤」为融合素材的融合怪兽在自己的场上或墓地存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。自己的卡组·墓地·除外状态的1张「烙印」魔法·陷阱卡加入手卡。那之后，选自己1张手卡回到卡组最下面。
function c45484331.initial_effect(c)
	-- 将卡号68468459（阿不思的落胤）登记为这张卡上记载的卡名，供后续判断相关融合素材使用。
	aux.AddCodeList(c,68468459)
	-- ①：需以「阿不思的落胤」为融合素材的融合怪兽在自己的场上或墓地存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,45484331)
	e1:SetCondition(c45484331.spcon)
	e1:SetTarget(c45484331.sptg)
	e1:SetOperation(c45484331.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。自己的卡组·墓地·除外状态的1张「烙印」魔法·陷阱卡加入手卡。那之后，选自己1张手卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,45484332)
	e2:SetTarget(c45484331.thtg)
	e2:SetOperation(c45484331.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义①效果所需的融合怪兽判定过滤器：目标是融合怪兽，融合素材包含阿不思的落胤，且处于我方场上表侧表示或存在于墓地。
function c45484331.spfilter(c)
	-- 判断目标是否同时满足：是融合怪兽，并且其融合素材中包含卡号68468459（阿不思的落胤）。
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459)
		and (c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 定义①效果的发动条件：检查自己场上或墓地是否存在满足spfilter条件的融合怪兽。
function c45484331.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 通过Duel.IsExistingMatchingCard确认自己的场上或墓地存在至少1张满足spfilter条件的融合怪兽，以此作为能否发动的判定。
	return Duel.IsExistingMatchingCard(c45484331.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
-- 定义①效果发动时的目标合法性判定：在chk==0时，确认自己主要怪兽区有空位，且这张卡本身可以被特殊召唤。
function c45484331.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有可用的主要怪兽区空格，以保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息：预告效果处理时进行特殊召唤，对象为这张卡（e:GetHandler()），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义①效果处理时的实际操作：若这张卡仍与当前效果关联，则将其特殊召唤到场上。
function c45484331.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己（tp）的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果可选的卡的条件：是‘烙印’魔法·陷阱卡，能够加入手牌；若位于除外区则必须是表侧表示（墓地/卡组没有表侧限制）。
function c45484331.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x15d) and c:IsAbleToHand()
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
-- 定义②效果发动时的合法性检查：确认卡组、墓地、除外区存在至少1张满足thfilter的‘烙印’魔法·陷阱卡；并设置后续操作信息：检索加入手牌以及将1张手卡放回卡组。
function c45484331.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组、墓地、除外区是否存在至少1张满足thfilter条件的‘烙印’魔法·陷阱卡，作为能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c45484331.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：效果处理时从卡组·墓地·除外区把1张满足条件的卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
	-- 设置操作信息：效果处理时随后选自己1张手卡放回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 定义②效果处理时的操作：先从卡组·墓地·除外区选择1张符合条件的‘烙印’魔法·陷阱卡加入手牌，成功后向对方展示并洗切卡组；之后选自己1张手卡放回卡组最下面。
function c45484331.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示消息：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让tp从自己的卡组、墓地、除外区中，选择1张满足thfilter条件且不受王家长眠之谷影响的‘烙印’魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45484331.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 判断条件：如果成功选到卡，将其加入手牌的操作实际生效，且该卡现在确实在手牌区域，则继续执行后续的返回卡组处理。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 将加入手牌的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 洗切卡组，因为检索后卡组顺序已改变。
		Duel.ShuffleDeck(tp)
		-- 向玩家发送选择提示消息：请选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从自己的手卡中选择1张能够返回卡组的卡（用于放回卡组最下面）。
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续的处理与前面的检索加入手牌处理不在同一时点，避免错过时点。
			Duel.BreakEffect()
			-- 洗切手卡，重置手卡顺序状态。
			Duel.ShuffleHand(tp)
			-- 将选中的手卡放回持有者的卡组最下面（SEQ_DECKBOTTOM），原因是效果处理（REASON_EFFECT）。
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
