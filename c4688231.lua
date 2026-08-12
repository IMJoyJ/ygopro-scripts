--メタルフォーゼ・ミスリエル
-- 效果：
-- 「炼装」怪兽＋灵摆怪兽
-- 「炼装勇士·秘银天使」的①的效果1回合只能使用1次。
-- ①：以自己墓地2张「炼装」卡和场上1张卡为对象才能发动。墓地的作为对象的卡回到卡组，场上的作为对象的卡回到持有者手卡。
-- ②：这张卡从场上送去墓地的场合才能发动。选1只自己的额外卡组的表侧表示的「炼装」灵摆怪兽或者自己墓地的「炼装」灵摆怪兽特殊召唤。
function c4688231.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用一张「炼装」怪兽和一张灵摆怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xe1),aux.FilterBoolFunction(Card.IsFusionType,TYPE_PENDULUM),true)
	-- ①：以自己墓地2张「炼装」卡和场上1张卡为对象才能发动。墓地的作为对象的卡回到卡组，场上的作为对象的卡回到持有者手卡。
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
-- 过滤满足条件的墓地「炼装」卡，用于选择返回卡组的卡片
function c4688231.retfilter1(c)
	return c:IsSetCard(0xe1) and c:IsAbleToDeck()
end
-- 过滤满足条件的场上卡，用于选择返回手牌的卡片
function c4688231.retfilter2(c)
	return c:IsAbleToHand()
end
-- 判断是否满足效果发动条件：场上有2张以上墓地「炼装」卡和1张场上卡
function c4688231.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查场上是否有至少2张满足条件的墓地「炼装」卡
	if chk==0 then return Duel.IsExistingTarget(c4688231.retfilter1,tp,LOCATION_GRAVE,0,2,nil)
		-- 检查场上是否有至少1张满足条件的场上卡
		and Duel.IsExistingTarget(c4688231.retfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的2张墓地「炼装」卡作为对象
	local g1=Duel.SelectTarget(tp,c4688231.retfilter1,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的1张场上卡作为对象
	local g2=Duel.SelectTarget(tp,c4688231.retfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：将选中的卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,g1:GetCount(),0,0)
	-- 设置效果处理信息：将选中的卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end
-- 处理效果发动后的操作：将对象卡按类型分别送回卡组或手牌
function c4688231.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local g1=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	-- 将墓地的卡送回卡组并判断是否需要洗切卡组
	if Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 获取实际被操作的卡片组
		local og=Duel.GetOperatedGroup()
		-- 若返回卡组的卡中有进入卡组的，则进行洗切卡组操作
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		local g2=g:Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
		-- 将场上的卡送回手牌
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
	end
end
-- 判断此效果是否满足发动条件：该卡从场上送去墓地
function c4688231.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤满足条件的「炼装」灵摆怪兽，用于特殊召唤
function c4688231.spfilter(c,e,tp)
	return c:IsSetCard(0xe1) and c:IsType(TYPE_PENDULUM) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若目标卡在墓地，则检查是否有可用怪兽区
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 若目标卡在额外卡组，则检查是否有可用特殊召唤区域
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 判断是否满足效果发动条件：场上有1只以上满足条件的「炼装」灵摆怪兽
function c4688231.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有至少1只满足条件的「炼装」灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c4688231.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置效果处理信息：特殊召唤1只「炼装」灵摆怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 处理效果发动后的操作：选择并特殊召唤符合条件的灵摆怪兽
function c4688231.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只「炼装」灵摆怪兽作为对象
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4688231.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡以指定方式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
