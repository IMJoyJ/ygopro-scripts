--雷鳥龍－サンダー・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把这张卡从手卡丢弃才能发动。「雷鸟龙-雷龙」以外的自己的墓地·除外状态的1只「雷龙」怪兽特殊召唤。
-- ②：这张卡被除外的场合或者从场上送去墓地的场合才能发动。自己手卡任意数量回到卡组。那之后，自己抽出回到卡组的数量。
function c83107873.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。「雷鸟龙-雷龙」以外的自己的墓地·除外状态的1只「雷龙」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83107873,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,83107873)
	e1:SetCost(c83107873.cost)
	e1:SetTarget(c83107873.target)
	e1:SetOperation(c83107873.operation)
	c:RegisterEffect(e1)
	c83107873.discard_effect=e1
	-- ②：这张卡被除外的场合或者从场上送去墓地的场合才能发动。自己手卡任意数量回到卡组。那之后，自己抽出回到卡组的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83107873,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,83107873)
	e2:SetTarget(c83107873.thtg)
	e2:SetOperation(c83107873.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c83107873.thcon)
	c:RegisterEffect(e3)
end
-- ①号效果的发动代价：检查并把手牌中的这张卡丢弃。
function c83107873.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为发动代价丢弃去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤条件：墓地或表侧除外状态的、卡名非「雷鸟龙-雷龙」的「雷龙」怪兽，且可以特殊召唤。
function c83107873.spfilter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x11c) and not c:IsCode(83107873) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备：检查自身怪兽区域是否有空位，以及是否存在可特殊召唤的目标。
function c83107873.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空余怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的墓地或除外状态是否存在至少1只满足特殊召唤条件的「雷龙」怪兽。
		and Duel.IsExistingMatchingCard(c83107873.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁信息：此效果包含从墓地或除外状态特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ①号效果的处理：在怪兽区域有空位的情况下，选择自己墓地或除外状态的1只符合条件的「雷龙」怪兽特殊召唤。
function c83107873.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有空余的怪兽区域，若无则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地或除外状态选择1只满足条件的「雷龙」怪兽（受「王家长眠之谷」影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c83107873.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②号效果从场上送去墓地时的发动条件：检查这张卡是否是从场上送去墓地。
function c83107873.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②号效果的发动准备：检查玩家是否可以抽卡，以及手牌中是否存在可以回到卡组的卡。
function c83107873.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己当前是否可以进行抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查自己手牌中是否存在至少1张可以回到卡组的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	-- 设置当前连锁的影响对象玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁信息：此效果包含将手牌中的卡送回卡组的操作。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- ②号效果的处理：让玩家选择手牌中任意数量的卡回到卡组洗切，然后抽出相同数量的卡。
function c83107873.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家（即发动效果的玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 提示玩家选择要送回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择手牌中任意数量（1到63张）可以送回卡组的卡。
	local g=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,1,63,nil)
	if g:GetCount()==0 then return end
	-- 将选中的手牌送回持有者的卡组并洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切该玩家的卡组。
	Duel.ShuffleDeck(p)
	-- 中断当前效果处理，使后续的抽卡处理与送回卡组不视为同时进行（造成错时点）。
	Duel.BreakEffect()
	-- 玩家抽出与送回卡组数量相同的卡。
	Duel.Draw(p,g:GetCount(),REASON_EFFECT)
end
