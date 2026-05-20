--宿神像ケルドウ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1只其他的天使族·地属性怪兽才能发动。这张卡从手卡特殊召唤。那之后，把1张「现世与冥界的逆转」或者有那个卡名记述的卡从卡组加入手卡。
-- ②：自己·对方回合，把场上·墓地的这张卡除外，以自己·对方的墓地的卡合计最多3张为对象才能发动（自己的场上或墓地有「现世与冥界的逆转」存在的场合，这个效果的对象变成最多5张）。那些卡回到卡组。
function c63542003.initial_effect(c)
	-- 注册「现世与冥界的逆转」为本卡记述的卡片密码
	aux.AddCodeList(c,17484499)
	-- ①：从手卡丢弃1只其他的天使族·地属性怪兽才能发动。这张卡从手卡特殊召唤。那之后，把1张「现世与冥界的逆转」或者有那个卡名记述的卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,63542003)
	e1:SetCost(c63542003.spcost)
	e1:SetTarget(c63542003.sptg)
	e1:SetOperation(c63542003.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把场上·墓地的这张卡除外，以自己·对方的墓地的卡合计最多3张为对象才能发动（自己的场上或墓地有「现世与冥界的逆转」存在的场合，这个效果的对象变成最多5张）。那些卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,63542004)
	-- 将场上或墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c63542003.tdtg)
	e2:SetOperation(c63542003.tdop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中除自身以外的天使族·地属性怪兽
function c63542003.cfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsDiscardable()
end
-- ①号效果的发动代价：从手卡丢弃1只其他的天使族·地属性怪兽
function c63542003.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除自身以外的天使族·地属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c63542003.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择手卡中1只其他的天使族·地属性怪兽丢弃
	Duel.DiscardHand(tp,c63542003.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 过滤条件：卡组中「现世与冥界的逆转」或记述有该卡名的卡
function c63542003.thfilter(c)
	-- 检查卡片是否为「现世与冥界的逆转」或记述有该卡名，且能加入手卡
	return aux.IsCodeOrListed(c,17484499) and c:IsAbleToHand()
end
-- ①号效果的发动准备：检查自身能否特殊召唤，以及卡组中是否存在可检索的卡
function c63542003.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域，且这张卡能否特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 且检查卡组中是否存在满足检索条件的卡
		and Duel.IsExistingMatchingCard(c63542003.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息：此效果包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置连锁信息：此效果包含从卡组将1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的处理：特殊召唤自身，那之后从卡组检索1张相关卡
function c63542003.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与效果相关，则将其在自己场上表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 且如果卡组中仍存在满足检索条件的卡
		and Duel.IsExistingMatchingCard(c63542003.thfilter,tp,LOCATION_DECK,0,1,nil) then
		-- 中断效果处理，使后续的检索处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从卡组选择1张满足检索条件的卡
		local g=Duel.SelectMatchingCard(tp,c63542003.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：场上表侧表示或墓地中的「现世与冥界的逆转」
function c63542003.filter(c)
	return c:IsCode(17484499) and (c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- ②号效果的发动准备：选择双方墓地的卡为对象，根据场上或墓地是否有「现世与冥界的逆转」决定最大对象数量
function c63542003.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	-- 检查双方墓地是否存在至少1张可以回到卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,e:GetHandler()) end
	local ct=5
	-- 若自己的场上或墓地没有「现世与冥界的逆转」存在，则最大对象数量限制为3张
	if not Duel.IsExistingMatchingCard(c63542003.filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) then ct=3 end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择双方墓地合计最多3张（或5张）可以回到卡组的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,ct,nil)
	-- 设置连锁信息：此效果包含将选中的卡送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ②号效果的处理：使作为对象的卡回到卡组
function c63542003.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将仍与效果相关的对象卡送回卡组并洗牌
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
