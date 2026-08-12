--ミュートリア進化研究所
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从手卡以及除外的自己怪兽之中选1只4星以下的「秘异三变」怪兽特殊召唤。
-- ②：自己场上的「秘异三变」怪兽的攻击力上升除外的自己的「秘异三变」卡的卡名种类×100。
-- ③：1回合1次，自己主要阶段才能发动。从手卡让1只「秘异三变」怪兽回到卡组最下面，自己从卡组抽1张。
function c34572613.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从手卡以及除外的自己怪兽之中选1只4星以下的「秘异三变」怪兽特殊召唤。
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
	-- 设置效果目标为场上的「秘异三变」怪兽
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
-- 过滤函数，用于筛选满足条件的「秘异三变」怪兽，包括等级不超过4星、可以特殊召唤、正面表示或在手牌中
function c34572613.spfilter(c,e,tp)
	return c:IsSetCard(0x157) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(4) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
-- 发动时处理效果，检查是否有满足条件的怪兽可特殊召唤，若有则提示玩家选择是否进行特殊召唤
function c34572613.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有怪兽区域可用，若无则不执行特殊召唤
	if Duel.GetMZoneCount(tp)<=0 then return end
	-- 获取满足特殊召唤条件的「秘异三变」怪兽组，包括手牌和除外区
	local g=Duel.GetMatchingGroup(c34572613.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,nil,e,tp)
	-- 判断是否有满足条件的怪兽且玩家选择进行特殊召唤
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(34572613,0)) then  --"是否要进行特殊召唤？"
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选除外区中正面表示的「秘异三变」怪兽
function c34572613.atkvalfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x157)
end
-- 计算攻击力提升值，为除外的「秘异三变」卡的卡名种类数乘以100
function c34572613.atkval(e,c)
	local tp=e:GetHandler():GetControler()
	-- 获取除外区中正面表示的「秘异三变」怪兽组
	local g=Duel.GetMatchingGroup(c34572613.atkvalfilter,tp,LOCATION_REMOVED,0,nil)
	return g:GetClassCount(Card.GetCode)*100
end
-- 过滤函数，用于筛选可送回卡组的「秘异三变」怪兽，包括类型为怪兽、可送回卡组
function c34572613.drtgfilter(c)
	return c:IsAbleToDeck() and c:IsSetCard(0x157) and c:IsType(TYPE_MONSTER)
end
-- 设置效果目标，检查是否可以抽卡并确认手牌中有可送回卡组的怪兽
function c34572613.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足抽卡和送回卡组的条件
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(c34572613.drtgfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息，指定要送回卡组的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息，指定要抽卡的数量和玩家
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 发动效果处理，选择要送回卡组的怪兽并执行抽卡
function c34572613.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的怪兽送回卡组
	local g=Duel.SelectMatchingCard(tp,c34572613.drtgfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 确认对方查看该怪兽
		Duel.ConfirmCards(1-tp,tc)
		-- 将怪兽送回卡组底部并判断是否成功送回
		if Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) then
			-- 若怪兽成功送回卡组，则从卡组抽一张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
