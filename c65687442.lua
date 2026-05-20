--Walkuren Ritt
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从手卡把「女武神」怪兽任意数量特殊召唤（同名卡最多1张）。这个效果把3只以上的怪兽特殊召唤的场合，直到下个回合的结束时自己受到的战斗伤害变成0。这张卡发动的回合的结束阶段，自己场上的怪兽全部回到持有者卡组。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「时间女神的恶作剧」加入手卡。
function c65687442.initial_effect(c)
	-- ①：从手卡把「女武神」怪兽任意数量特殊召唤（同名卡最多1张）。这个效果把3只以上的怪兽特殊召唤的场合，直到下个回合的结束时自己受到的战斗伤害变成0。这张卡发动的回合的结束阶段，自己场上的怪兽全部回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65687442,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c65687442.sptg)
	e1:SetOperation(c65687442.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1张「时间女神的恶作剧」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65687442,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,65687442)
	-- 将墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c65687442.thtg)
	e2:SetOperation(c65687442.thop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可以特殊召唤的「女武神」怪兽
function c65687442.filter(c,e,tp)
	return c:IsSetCard(0x122) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果发动的可行性检测
function c65687442.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在可以特殊召唤的「女武神」怪兽
		and Duel.IsExistingMatchingCard(c65687442.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤手卡中的「女武神」怪兽，并根据数量适用战斗伤害为0的效果，以及注册结束阶段怪兽回卡组的效果
function c65687442.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取手卡中所有可以特殊召唤的「女武神」怪兽
	local g=Duel.GetMatchingGroup(c65687442.filter,tp,LOCATION_HAND,0,nil,e,tp)
	if ft<=0 or g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择任意数量且卡名各不相同的「女武神」怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	if sg and #sg>0 then
		-- 将选中的怪兽特殊召唤，并获取成功特殊召唤的怪兽数量
		local ct=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		if ct>2 then
			-- 这个效果把3只以上的怪兽特殊召唤的场合，直到下个回合的结束时自己受到的战斗伤害变成0。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			-- 注册“直到下个回合的结束时自己受到的战斗伤害变成0”的效果
			Duel.RegisterEffect(e1,tp)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡发动的回合的结束阶段，自己场上的怪兽全部回到持有者卡组。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetOperation(c65687442.tdop)
		-- 注册在回合结束阶段触发的延迟效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 结束阶段将自己场上的怪兽全部回到持有者卡组的效果处理
function c65687442.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有可以回到卡组的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,0,nil)
	-- 将这些怪兽全部送回持有者卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 过滤卡组中可以加入手卡的「时间女神的恶作剧」
function c65687442.thfilter(c)
	return c:IsCode(92182447) and c:IsAbleToHand()
end
-- 检索效果发动的可行性检测
function c65687442.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「时间女神的恶作剧」
	if chk==0 then return Duel.IsExistingMatchingCard(c65687442.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索卡片加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 从卡组将1张「时间女神的恶作剧」加入手卡的效果处理
function c65687442.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「时间女神的恶作剧」
	local g=Duel.SelectMatchingCard(tp,c65687442.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
