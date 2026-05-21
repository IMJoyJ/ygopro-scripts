--無限起動スクレイパー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只机械族·地属性怪兽解放才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地5只机械族·地属性怪兽为对象才能发动。那些怪兽回到卡组洗切。那之后，自己从卡组抽2张。
function c97316367.initial_effect(c)
	-- ①：把自己场上1只机械族·地属性怪兽解放才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97316367,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,97316367)
	e1:SetCost(c97316367.spcost)
	e1:SetTarget(c97316367.sptg)
	e1:SetOperation(c97316367.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地5只机械族·地属性怪兽为对象才能发动。那些怪兽回到卡组洗切。那之后，自己从卡组抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97316367,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,97316368)
	-- 把墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c97316367.drtg)
	e2:SetOperation(c97316367.drop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上可解放的机械族·地属性怪兽，且解放后能腾出怪兽区域供特殊召唤
function c97316367.cfilter(c,tp)
	-- 检查卡片是否为机械族·地属性，且解放该卡后自己场上有可用的怪兽区域
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤效果的代价处理函数：解放自己场上1只机械族·地属性怪兽
function c97316367.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放1只满足条件的怪兽作为代价
	if chk==0 then return Duel.CheckReleaseGroup(tp,c97316367.cfilter,1,nil,tp) end
	-- 玩家选择1只满足条件的怪兽准备解放
	local g=Duel.SelectReleaseGroup(tp,c97316367.cfilter,1,1,nil,tp)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤效果的目标处理函数：检查自身是否能特殊召唤并设置操作信息
function c97316367.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁信息，表示此效果包含特殊召唤这张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的运行空间（效果处理）：将这张卡从手卡守备表示特殊召唤
function c97316367.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤自己墓地可以回到卡组的机械族·地属性怪兽
function c97316367.tdfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToDeck()
end
-- 回卡组抽卡效果的目标处理函数：选择墓地5只机械族·地属性怪兽作为对象，并检查是否能抽卡
function c97316367.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c97316367.tdfilter(chkc) end
	-- 检查玩家当前是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查自己墓地是否存在5只（除这张卡以外）可以回到卡组的机械族·地属性怪兽
		and Duel.IsExistingTarget(c97316367.tdfilter,tp,LOCATION_GRAVE,0,5,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地5只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c97316367.tdfilter,tp,LOCATION_GRAVE,0,5,5,e:GetHandler())
	-- 设置连锁信息，表示此效果包含将选中的卡片送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置连锁信息，表示此效果包含玩家从卡组抽2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 回卡组抽卡效果的运行空间（效果处理）：将对象怪兽送回卡组洗切，之后抽2张卡
function c97316367.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍对该效果有效的对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg==0 then return end
	-- 将对象怪兽送回持有者的卡组并洗卡
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果被操作的卡片中存在回到了主卡组的卡，则洗切玩家的卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果处理，使后续的抽卡处理与回卡组不视为同时进行
		Duel.BreakEffect()
		-- 玩家从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
