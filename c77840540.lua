--超進化の繭
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：有装备卡装备的自己·对方场上1只昆虫族怪兽解放，从卡组把1只昆虫族怪兽无视召唤条件特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只昆虫族怪兽为对象才能发动。那只怪兽回到卡组洗切。那之后，自己从卡组抽1张。
function c77840540.initial_effect(c)
	-- ①：有装备卡装备的自己·对方场上1只昆虫族怪兽解放，从卡组把1只昆虫族怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c77840540.target)
	e1:SetOperation(c77840540.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只昆虫族怪兽为对象才能发动。那只怪兽回到卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,77840540)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置发动cost为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c77840540.tdtg)
	e2:SetOperation(c77840540.tdop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示、有装备卡装备、且可以被效果解放的昆虫族怪兽
function c77840540.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsReleasableByEffect()
		and c:GetEquipCount()>0
end
-- 过滤条件：卡组中可以无视召唤条件特殊召唤的昆虫族怪兽
function c77840540.filter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ①效果的发动准备与合法性检测
function c77840540.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local loc=LOCATION_MZONE
		-- 若自己场上没有空余的怪兽区域，则只能解放自己场上的怪兽
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then loc=0 end
		-- 检查场上是否存在满足解放条件的昆虫族怪兽
		return Duel.IsExistingMatchingCard(c77840540.cfilter,tp,LOCATION_MZONE,loc,1,nil)
			-- 检查卡组中是否存在可以特殊召唤的昆虫族怪兽
			and Duel.IsExistingMatchingCard(c77840540.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置操作信息：包含解放1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
	-- 设置操作信息：包含从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：解放场上1只怪兽，并从卡组特殊召唤1只昆虫族怪兽
function c77840540.activate(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_MZONE
	-- 若自己场上没有空余的怪兽区域，则只能选择解放自己场上的怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then loc=0 end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c77840540.cfilter,tp,LOCATION_MZONE,loc,1,1,nil)
	-- 成功解放选择的怪兽时
	if g:GetCount()>0 and Duel.Release(g,REASON_EFFECT)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足特殊召唤条件的昆虫族怪兽
		local sg=Duel.SelectMatchingCard(tp,c77840540.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选择的怪兽无视召唤条件表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
-- 过滤条件：自己墓地可以回到卡组的昆虫族怪兽
function c77840540.tdfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToDeck()
end
-- ②效果的发动准备、对象选择与合法性检测
function c77840540.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c77840540.tdfilter(chkc) end
	-- 检查自己墓地是否存在可以回到卡组的昆虫族怪兽
	if chk==0 then return Duel.IsExistingTarget(c77840540.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 且自己是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只昆虫族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c77840540.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：包含将选择的对象送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：包含抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理：对象怪兽回到卡组洗切，之后自己抽1张
function c77840540.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将对象怪兽送回卡组并洗切
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 若对象怪兽回到了主卡组，则洗切卡组
	if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	if tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 中断当前效果处理，使后续的抽卡处理不与回卡组同时进行
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
