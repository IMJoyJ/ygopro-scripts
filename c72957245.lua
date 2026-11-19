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
-- 过滤条件函数：筛选可被表侧守备表示特殊召唤的岩石族怪兽
function c72957245.filter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的目标选择与检查函数：检查场上怪兽区空位并确认墓地存在岩石族怪兽，选择1只作为对象并登记特召操作信息
function c72957245.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c72957245.filter(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否存在可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只可成为对象的岩石族怪兽
		and Duel.IsExistingTarget(c72957245.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送选择提示：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只岩石族怪兽作为对象
	local g=Duel.SelectTarget(tp,c72957245.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统登记操作信息：将会特殊召唤所选对象的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤条件函数：筛选卡组中等级4以下的岩石族怪兽
function c72957245.cfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_ROCK)
end
-- ①效果的处理函数：将对象怪兽表侧守备表示特殊召唤，若特召的是「魔救」怪兽则可再从卡组选1只4星以下岩石族怪兽洗卡后置于卡组最上方并确认
function c72957245.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象选择的墓地岩石族怪兽
	local tc=Duel.GetFirstTarget()
	-- 将对象怪兽守备表示特殊召唤，若特召成功且其为「魔救」怪兽、卡组存在4星以下岩石族怪兽时，询问玩家是否放置到卡组最上面
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 and tc:IsSetCard(0x140) and Duel.IsExistingMatchingCard(c72957245.cfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(72957245,0)) then  --"是否把卡在卡组最上面放置？"
		-- 中断当前处理，将特殊召唤与从卡组选卡放置分为不同时点处理
		Duel.BreakEffect()
		-- 让玩家从自己卡组选择1只4星以下的岩石族怪兽
		local dc=Duel.SelectMatchingCard(tp,c72957245.cfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		-- 洗切发动玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 将选出的岩石族怪兽移动到卡组最上方
		Duel.MoveSequence(dc,SEQ_DECKTOP)
		-- 向双方展示确认置于卡组最上方的那张卡
		Duel.ConfirmDecktop(tp,1)
	end
end
