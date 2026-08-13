--銀河の修道師
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只「光子」超量怪兽或者「银河」超量怪兽为对象才能发动。把手卡的这张卡在那只怪兽下面重叠作为超量素材。
-- ②：这张卡召唤·特殊召唤成功的场合，从自己墓地的「光子」卡以及「银河」卡之中以合计5张为对象才能发动（同名卡最多1张）。那些卡加入卡组洗切。那之后，自己从卡组抽2张。
function c28770951.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：以自己场上1只「光子」超量怪兽或者「银河」超量怪兽为对象才能发动。把手卡的这张卡在那只怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28770951,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,28770951)
	e1:SetTarget(c28770951.mattg)
	e1:SetOperation(c28770951.matop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，从自己墓地的「光子」卡以及「银河」卡之中以合计5张为对象才能发动（同名卡最多1张）。那些卡加入卡组洗切。那之后，自己从卡组抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28770951,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,28770951)
	e2:SetTarget(c28770951.drtg)
	e2:SetOperation(c28770951.drop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 检查该卡是否为表侧表示的「光子」或「银河」字段的超量怪兽，用于①选择对象时过滤目标。
function c28770951.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x55,0x7b) and c:IsType(TYPE_XYZ)
end
-- ①的发动条件判定：确认自己场上存在1只表侧表示的「光子」或「银河」超量怪兽，且手牌中的这张卡能够叠放在其下方作为超量素材；选择该怪兽为对象。
function c28770951.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28770951.matfilter(chkc) end
	-- 发动时确认：自己场上有满足条件的超量怪兽可供选择，且这张手牌可以重叠为超量素材。
	if chk==0 then return Duel.IsExistingTarget(c28770951.matfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 向操作玩家显示选择效果对象的提示信息（“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只表侧表示的「光子」或「银河」超量怪兽作为①的对象。
	Duel.SelectTarget(tp,c28770951.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①的效果处理：若这张卡仍与效果相关且可以重叠，目标怪兽仍与效果相关且不受该效果免疫，则将这张卡重叠到目标怪兽下方作为超量素材。
function c28770951.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsCanOverlay() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 将手牌中的这张卡作为超量素材叠放到对象怪兽下方。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
-- 检查墓地的卡是否为「光子」或「银河」字段、能够返回卡组且能成为效果对象，用于②选择弹回卡组的对象。
function c28770951.filter(c,e)
	return c:IsSetCard(0x55,0x7b) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- ②的发动条件判定与对象选择：这张卡召唤·特殊召唤成功的场合，从自己墓地的「光子」卡和「银河」卡中选择合计5张卡名互不相同的卡为对象，并确认自己可以抽2张；设置返回卡组和抽卡的操作信息。
function c28770951.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28770951.filter(chkc,e) end
	-- 获取自己墓地中所有满足条件的「光子」或「银河」卡片组。
	local g=Duel.GetMatchingGroup(c28770951.filter,tp,LOCATION_GRAVE,0,nil,e)
	-- 确认墓地可选择的对象中不同卡名数量不少于5，且自己可以抽2张卡，满足②的发动条件。
	if chk==0 then return g:GetClassCount(Card.GetCode)>=5 and Duel.IsPlayerCanDraw(tp,2) end
	-- 显示选择返回卡组的卡的提示消息（“请选择要返回卡组的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 设置额外选择限制：所选卡片的卡名必须互不相同，以符合“同名卡最多1张”。
	aux.GCheckAdditional=aux.dncheck
	-- 让玩家从符合条件的墓地卡片中选出5张（卡名互不相同，且必须为5张）作为弹回卡组的对象。
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,5,5)
	-- 清除额外选择限制，恢复默认选择规则。
	aux.GCheckAdditional=nil
	-- 将选中的5张卡设置为当前连锁的对象，供效果处理时使用。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：这些卡将返回卡组，数量为对象数（5张）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
	-- 设置操作信息：之后自己从卡组抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ②的效果处理：将对象卡返回持有者卡组洗切；若有卡实际返回卡组，则接着让自己抽2张卡（通过中断效果分成不同时点处理）。
function c28770951.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得连锁对象中仍与效果相关的卡片（排除已离场或不受影响的卡）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg==0 then return end
	-- 将对象卡送回持有者卡组，并标记需要洗切卡组。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 取得上一步返回卡组操作实际处理的卡片组。
	local g=Duel.GetOperatedGroup()
	-- 如果返回的卡中有卡进入卡组，则洗切卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果处理，使弹回卡组与抽卡不视为同一时点，避免错误联动时点。
		Duel.BreakEffect()
		-- 让自己抽2张卡。
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
