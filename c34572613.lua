--ミュートリア進化研究所
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从手卡以及除外的自己怪兽之中选1只4星以下的「秘异三变」怪兽特殊召唤。
-- ②：自己场上的「秘异三变」怪兽的攻击力上升除外的自己的「秘异三变」卡的卡名种类×100。
-- ③：1回合1次，自己主要阶段才能发动。从手卡让1只「秘异三变」怪兽回到卡组最下面，自己从卡组抽1张。
function c34572613.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从手卡以及除外的自己怪兽之中选1只4星以下的「秘异三变」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,34572613+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c34572613.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「秘异三变」怪兽的攻击力上升除外的自己的「秘异三变」卡的卡名种类×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设定该攻击力上升效果仅适用于持有「秘异三变」（0x157）字段的怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x157))
	e2:SetValue(c34572613.atkval)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己主要阶段才能发动。从手卡让1只「秘异三变」怪兽回到卡组最下面，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34572613,1))  --"回到卡组并抽卡"
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c34572613.drtg)
	e3:SetOperation(c34572613.drop)
	c:RegisterEffect(e3)
end
-- 定义①效果的特殊召唤候选卡筛选条件：需为4星以下的「秘异三变」怪兽，能够被特殊召唤，且位于手牌或表侧表示的除外区。
function c34572613.spfilter(c,e,tp)
	return c:IsSetCard(0x157) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(4) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
-- ①效果的发动处理：在拥有可用怪兽区的前提下，先从手牌和除外区筛选候选组，经玩家确认后选择1只，以表侧表示特殊召唤。
function c34572613.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的主要怪兽区是否有可用空格；若无空位则无法特殊召唤，直接终止处理。
	if Duel.GetMZoneCount(tp)<=0 then return end
	-- 获取手牌及除外区中所有满足spfilter条件的「秘异三变」怪兽，作为本次特殊召唤的候选集合。
	local g=Duel.GetMatchingGroup(c34572613.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,nil,e,tp)
	-- 若存在候选卡，则询问玩家是否发动特殊召唤；玩家选择“是”才继续后续选择与召唤。
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(34572613,0)) then  --"是否要进行特殊召唤？"
		-- 弹出选择提示消息，提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义统计攻击力上升值时的除外区卡牌筛选条件：需为表侧表示且属于「秘异三变」字段。
function c34572613.atkvalfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x157)
end
-- 计算攻击力上升数值：统计除外区自己的表侧「秘异三变」卡的不同卡名数量，乘以100作为上升值。
function c34572613.atkval(e,c)
	local tp=e:GetHandler():GetControler()
	-- 获取除外区自己的表侧「秘异三变」卡集合，用于计算卡名种类数。
	local g=Duel.GetMatchingGroup(c34572613.atkvalfilter,tp,LOCATION_REMOVED,0,nil)
	return g:GetClassCount(Card.GetCode)*100
end
-- 定义③效果中可送回卡组的卡筛选条件：需为「秘异三变」怪兽且能够返回卡组。
function c34572613.drtgfilter(c)
	return c:IsAbleToDeck() and c:IsSetCard(0x157) and c:IsType(TYPE_MONSTER)
end
-- ③效果的发动条件检查与操作信息登记：确认自己可以抽卡、手牌存在符合条件的「秘异三变」怪兽，并登记回卡组与抽卡信息。
function c34572613.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点判定：当处于条件检查阶段时，必须满足自己可以抽1张卡，且手牌中至少存在1只符合drtgfilter条件的「秘异三变」怪兽。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(c34572613.drtgfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 登记本次连锁的操作信息：包含1张从手卡返回卡组的处理分类（CATEGORY_TODECK）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 登记本次连锁的操作信息：包含抽1张卡的处理分类（CATEGORY_DRAW）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ③效果的实际处理：从手牌选择1只「秘异三变」怪兽，给对方确认后送回卡组最下面；若送回成功且该卡在卡组中，则自己抽1张卡。
function c34572613.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示消息，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手牌中选择1只满足drtgfilter条件的「秘异三变」怪兽。
	local g=Duel.SelectMatchingCard(tp,c34572613.drtgfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		-- 将选择的卡送入持有者卡组最底部，并确认送入成功且该卡位于卡组中，才继续执行抽卡。
		if Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) then
			-- 自己从卡组抽1张卡。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
