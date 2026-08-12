--スプリガンズ・キット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：需以「阿不思的落胤」为融合素材的融合怪兽在自己的场上或墓地存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。自己的卡组·墓地·除外状态的1张「烙印」魔法·陷阱卡加入手卡。那之后，选自己1张手卡回到卡组最下面。
function c45484331.initial_effect(c)
	-- 注册此卡具有「阿不思的落胤」的卡名信息
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
-- 过滤函数，用于检测满足条件的融合怪兽（以阿不思的落胤为素材且在场上或墓地）
function c45484331.spfilter(c)
	-- 检测怪兽是否以阿不思的落胤为融合素材
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459)
		and (c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 判断场上或墓地是否存在以阿不思的落胤为素材的融合怪兽
function c45484331.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上或墓地是否存在以阿不思的落胤为素材的融合怪兽
	return Duel.IsExistingMatchingCard(c45484331.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
-- 设置特殊召唤的条件检查
function c45484331.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤的处理函数
function c45484331.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于检索满足条件的「烙印」魔法·陷阱卡
function c45484331.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x15d) and c:IsAbleToHand()
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
-- 设置效果处理的目标和操作信息
function c45484331.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的「烙印」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c45484331.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置将卡加入手牌的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
	-- 设置将手卡送回卡组的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，执行检索与送回卡组的操作
function c45484331.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「烙印」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45484331.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 确认选择的卡已加入手牌并进行后续处理
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方确认所选卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切卡组
		Duel.ShuffleDeck(tp)
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择要送回卡组的手卡
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 洗切手牌
			Duel.ShuffleHand(tp)
			-- 将选中的手卡送回卡组底部
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
