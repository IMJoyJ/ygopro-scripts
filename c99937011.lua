--剣神官ムドラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1只其他的天使族·地属性怪兽才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1张「守墓的陷阱」在自己的魔法与陷阱区域表侧表示放置。
-- ②：自己·对方回合，把场上·墓地的这张卡除外，以自己·对方的墓地的卡合计最多3张为对象才能发动（自己的场上或墓地有「现世与冥界的逆转」存在的场合，这个效果的对象变成最多5张）。那些卡回到卡组。
function c99937011.initial_effect(c)
	-- 记录这张卡的效果中提到的「现世与冥界的逆转」（密码17484499），以便在效果处理时查询场上或墓地是否存在该卡。
	aux.AddCodeList(c,17484499)
	-- ①：从手卡丢弃1只其他的天使族·地属性怪兽才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1张「守墓的陷阱」在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,99937011)
	e1:SetCost(c99937011.spcost)
	e1:SetTarget(c99937011.sptg)
	e1:SetOperation(c99937011.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把场上·墓地的这张卡除外，以自己·对方的墓地的卡合计最多3张为对象才能发动（自己的场上或墓地有「现世与冥界的逆转」存在的场合，这个效果的对象变成最多5张）。那些卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,99937012)
	-- 设置②效果的发动代价为：把这张卡从场上或墓地除外（作为发动COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c99937011.tdtg)
	e2:SetOperation(c99937011.tdop)
	c:RegisterEffect(e2)
end
-- 定义用于①效果丢弃手牌的过滤条件：手卡中1只其他的天使族·地属性怪兽，且可以被丢弃。
function c99937011.cfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsDiscardable()
end
-- ①效果的COST处理：发动前检查手牌是否存在符合条件的其他怪兽；发动时丢弃1张作为COST。
function c99937011.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- COST合法性检查：确认手牌中存在至少1只除这张卡自身以外的、满足天使族·地属性且可丢弃的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c99937011.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 支付COST：从手卡丢弃1只满足过滤条件且不是这张卡的天使族·地属性怪兽。
	Duel.DiscardHand(tp,c99937011.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 定义检索「守墓的陷阱」的过滤函数：卡名是守墓的陷阱（密码98715423）且不是禁止卡，即可被放置到魔法与陷阱区域。
function c99937011.stfilter(c)
	return c:IsCode(98715423) and not c:IsForbidden()
end
-- ①效果的发动条件：自己主要怪兽区有空位，且这张卡能够被特殊召唤。
function c99937011.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁将包含特殊召唤这张卡的操作信息，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：先特殊召唤这张卡；若成功且后场有空位、卡组有「守墓的陷阱」，则询问玩家是否将其表侧放置到自己的魔法与陷阱区域。
function c99937011.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍然与效果关联，然后以表侧攻击表示特殊召唤这张卡；只有特殊召唤成功才继续后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 确认自己的魔法与陷阱区域有空位，才能继续处理放置「守墓的陷阱」。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认卡组中存在可放置的「守墓的陷阱」（卡名正确且不是禁止卡）。
		and Duel.IsExistingMatchingCard(c99937011.stfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否选择将卡组中的「守墓的陷阱」表侧放置到自己的魔法与陷阱区域。
		and Duel.SelectYesNo(tp,aux.Stringid(99937011,0)) then  --"是否选「守墓的陷阱」上场？"
		-- 中断当前效果处理，使后续放置「守墓的陷阱」作为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 向玩家发送选择提示，缓存“请选择要放置到场上的卡”的提示文字，用于选择对话框。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从卡组中选择1张「守墓的陷阱」（过滤函数已保证满足条件）。
		local tc=Duel.SelectMatchingCard(tp,c99937011.stfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		-- 将选择的「守墓的陷阱」表侧表示放置到自己的魔法与陷阱区域，并立即适用其效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
-- 定义判断「现世与冥界的逆转」是否存在的过滤函数：该卡在场上表侧表示或存在于墓地。
function c99937011.filter(c)
	return c:IsCode(17484499) and (c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- ②效果的发动条件与对象选择：以双方墓地的卡为对象，数量为1到ct（无「现世与冥界的逆转」时ct=3，有该卡时ct=5）；同时检查双方墓地存在可回卡组的卡。
function c99937011.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	-- 发动合法性检查：确认双方墓地存在至少1张可返回卡组的卡（排除这张卡自身）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,e:GetHandler()) end
	local ct=5
	-- 根据场上或墓地是否存在「现世与冥界的逆转」来决定可选对象数量上限：存在时ct=5，不存在时ct=3。
	if not Duel.IsExistingMatchingCard(c99937011.filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) then ct=3 end
	-- 向玩家发送选择提示，缓存“请选择要返回卡组的卡”的提示文字，用于选择对话框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择双方墓地中1到ct张可返回卡组的卡作为效果对象，并标记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,ct,nil)
	-- 设置本次连锁将包含把对象卡返回卡组的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ②效果处理：将仍与效果关联的对象卡全部洗回持有者卡组。
function c99937011.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中记录的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将对象卡以效果送回持有者卡组，并执行洗牌。
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
