--魔救の息吹
-- 效果：
-- ①：以自己墓地1只岩石族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果把「魔救」怪兽特殊召唤的场合，可以再从卡组选1只4星以下的岩石族怪兽在卡组最上面放置。
function c72957245.initial_effect(c)
	-- ①：以自己墓地1只岩石族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果把「魔救」怪兽特殊召唤的场合，可以再从卡组选1只4星以下的岩石族怪兽在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c72957245.target)
	e1:SetOperation(c72957245.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以守备表示特殊召唤的岩石族怪兽
function c72957245.filter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备，处理取对象判定和发动条件检查
function c72957245.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c83764718.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的岩石族怪兽
		and Duel.IsExistingTarget(c72957245.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的岩石族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c72957245.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤卡组中4星以下的岩石族怪兽
function c72957245.cfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_ROCK)
end
-- 效果①的处理，将目标怪兽特殊召唤，若为「魔救」怪兽则可选择将卡组中1只4星以下岩石族怪兽置于卡组最上方
function c72957245.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于墓地且成功守备表示特殊召唤，且该怪兽为「魔救」怪兽，且自己卡组有4星以下岩石族怪兽，则玩家可以选择是否发动后续效果
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 and tc:IsSetCard(0x140) and Duel.IsExistingMatchingCard(c72957245.cfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(72957245,0)) then  --"是否把卡在卡组最上面放置？"
		-- 中断当前效果处理，使后续的卡组放置处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 从卡组选择1只4星以下的岩石族怪兽
		local dc=Duel.SelectMatchingCard(tp,c72957245.cfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		-- 将卡组洗牌
		Duel.ShuffleDeck(tp)
		-- 将选择的怪兽移动到卡组最上方
		Duel.MoveSequence(dc,SEQ_DECKTOP)
		-- 确认卡组最上方的一张卡
		Duel.ConfirmDecktop(tp,1)
	end
end
