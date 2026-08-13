--メタルフォーゼ・ミスリエル
-- 效果：
-- 「炼装」怪兽＋灵摆怪兽
-- 「炼装勇士·秘银天使」的①的效果1回合只能使用1次。
-- ①：以自己墓地2张「炼装」卡和场上1张卡为对象才能发动。墓地的作为对象的卡回到卡组，场上的作为对象的卡回到持有者手卡。
-- ②：这张卡从场上送去墓地的场合才能发动。选1只自己的额外卡组的表侧表示的「炼装」灵摆怪兽或者自己墓地的「炼装」灵摆怪兽特殊召唤。
function c4688231.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材为1只「炼装」怪兽和1只灵摆怪兽（各1只）。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xe1),aux.FilterBoolFunction(Card.IsFusionType,TYPE_PENDULUM),true)
	-- 「炼装勇士·秘银天使」的①的效果1回合只能使用1次。①：以自己墓地2张「炼装」卡和场上1张卡为对象才能发动。墓地的作为对象的卡回到卡组，场上的作为对象的卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,4688231)
	e2:SetTarget(c4688231.rettg)
	e2:SetOperation(c4688231.retop)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上送去墓地的场合才能发动。选1只自己的额外卡组的表侧表示的「炼装」灵摆怪兽或者自己墓地的「炼装」灵摆怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c4688231.spcon)
	e3:SetTarget(c4688231.sptg)
	e3:SetOperation(c4688231.spop)
	c:RegisterEffect(e3)
end
-- 定义①效果回卡组的对象过滤器：选择自己墓地中满足「炼装」字段且可以返回卡组的卡。
function c4688231.retfilter1(c)
	return c:IsSetCard(0xe1) and c:IsAbleToDeck()
end
-- 定义①效果回手牌的对象过滤器：选择场上可以返回持有者手卡的卡（不限制位置和阵营）。
function c4688231.retfilter2(c)
	return c:IsAbleToHand()
end
-- ①效果的取对象处理：先判断是否为连锁对象判定时（chkc则返回false）；再在发动时点检查是否至少存在2张可回卡组的墓地「炼装」卡和1张可回手牌的场上卡。
function c4688231.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己墓地是否存在至少2张满足retfilter1（「炼装」且可回卡组）的卡。
	if chk==0 then return Duel.IsExistingTarget(c4688231.retfilter1,tp,LOCATION_GRAVE,0,2,nil)
		-- 检查场上是否存在至少1张满足retfilter2（可回手牌）的卡。
		and Duel.IsExistingTarget(c4688231.retfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示选择提示，要求选择要返回卡组的墓地「炼装」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择2张满足retfilter1的卡，并登记为当前连锁的对象。
	local g1=Duel.SelectTarget(tp,c4688231.retfilter1,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 向玩家显示选择提示，要求选择要返回手牌的场上卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从场上选择1张满足retfilter2的卡，并登记为当前连锁的对象。
	local g2=Duel.SelectTarget(tp,c4688231.retfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：登记将选中的墓地对象卡（g1）返回卡组，处理数量为g1的张数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,g1:GetCount(),0,0)
	-- 设置操作信息：登记将选中的场上对象卡（g2）返回持有者手卡，处理数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end
-- ①效果处理：获取本次连锁的对象并筛选出仍与效果相关的卡；将其中位于墓地的对象卡送回卡组并洗牌；再将位于场上的对象卡送回持有者手卡。
function c4688231.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡组，并过滤掉已与效果失去联系的对象（例如已离场或转移控制权）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local g1=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	-- 将墓地对象卡送回持有者卡组并指定洗牌；若实际有卡被送回（返回值不等于0），才继续处理回手牌。
	if Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 获取刚才被送回卡组的实际卡组，用于判断是否需要洗切卡组。
		local og=Duel.GetOperatedGroup()
		-- 如果被送回卡组的卡中有卡实际位于卡组，则洗切持有者的卡组。
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		local g2=g:Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
		-- 将场上对象卡返回持有者手卡。
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件：判断这张卡从场上被送去墓地（之前所在位置为场上）。
function c4688231.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果的选卡过滤：选择自己的墓地或额外卡组表侧表示的「炼装」灵摆怪兽，且其能够被特殊召唤；并根据来源检查对应区域是否有空位。
function c4688231.spfilter(c,e,tp)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_PENDULUM) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若候选卡在墓地，则要求自己场上有空余的主怪兽区才能从墓地特殊召唤。
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 若候选卡在额外卡组（表侧表示），则要求有可用的额外怪兽区/特殊召唤区域才能从额外卡组特殊召唤。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ②效果的target：检查是否存在至少1只满足条件的可特殊召唤的「炼装」灵摆怪兽；若存在，则登记特殊召唤的操作信息。
function c4688231.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查：自己墓地或额外卡组是否存在至少1只满足spfilter条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c4688231.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 登记本次效果将进行特殊召唤的操作信息：从墓地或额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- ②效果处理：从符合条件的卡中选择1只「炼装」灵摆怪兽，以表侧表示特殊召唤。
function c4688231.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 在符合条件的卡中选择1只（使用aux.NecroValleyFilter过滤，避开王家长眠之谷等影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4688231.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上，并按常规检查召唤条件和苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
