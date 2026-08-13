--溟界の蛇睡蓮
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只爬虫类族怪兽送去墓地。那之后，自己墓地有爬虫类族怪兽5种类以上存在的场合，可以从自己墓地把1只爬虫类族怪兽特殊召唤。
function c24050692.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只爬虫类族怪兽送去墓地。那之后，自己墓地有爬虫类族怪兽5种类以上存在的场合，可以从自己墓地把1只爬虫类族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,24050692+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c24050692.target)
	e1:SetOperation(c24050692.activate)
	c:RegisterEffect(e1)
end
-- 定义卡组送墓的筛选条件：对象必须是爬虫类族怪兽且可以被送去墓地。
function c24050692.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_REPTILE) and c:IsAbleToGrave()
end
-- 效果的发动条件与操作预告：检查卡组是否存在至少1只符合条件的爬虫类族怪兽，并设置本次效果将把卡组的1张卡送去墓地。
function c24050692.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法判定：卡组中存在至少1只可送去墓地的爬虫类族怪兽时才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c24050692.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统预告本次效果包含把卡组送去墓地的处理（数量为1张，对象在效果处理时选择），供连锁判断使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 定义通用筛选条件：对象为爬虫类族怪兽。
function c24050692.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_REPTILE)
end
-- 定义可特殊召唤的筛选条件：是爬虫类族怪兽且可以被当前效果特殊召唤。
function c24050692.spfilter(c,e,tp)
	return c24050692.cfilter(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：从卡组选1只爬虫类族怪兽送去墓地，若送墓成功且自己场上怪兽区有空位、墓地爬虫类族怪兽种类达到5种以上、并存在可特殊召唤的对象，则询问玩家是否进行特殊召唤，选择后将其特殊召唤。
function c24050692.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要送去墓地的卡”的提示信息，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己卡组选择1只满足条件的爬虫类族怪兽（效果处理时不取对象，临时选择）。
	local g=Duel.SelectMatchingCard(tp,c24050692.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功选出卡并以效果原因送去墓地（送墓数量大于0），才继续后续特殊召唤判定。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0
		-- 确认刚才送去墓地的卡确实处于墓地（避免被其他效果移动位置）。
		and Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_GRAVE)
		-- 检查自己场上是否有可用的怪兽区域，确保后续特殊召唤能正常进行。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 统计自己墓地中爬虫类族怪兽的不同卡名种类数，判断是否达到5种以上。
		and Duel.GetMatchingGroup(c24050692.cfilter,tp,LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)>=5
		-- 检查墓地是否存在至少1只不受王家长眠之谷等效果影响、且可被本次效果特殊召唤的爬虫类族怪兽。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c24050692.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 所有条件满足后，弹出是否选择框，询问玩家是否要从墓地特殊召唤怪兽。
		and Duel.SelectYesNo(tp,aux.Stringid(24050692,0)) then  --"是否选怪兽特殊召唤？"
		-- 中断当前效果处理，将后续特殊召唤作为“那之后”的独立处理，错开时点。
		Duel.BreakEffect()
		-- 显示“请选择要特殊召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从自己墓地选择1只符合条件的爬虫类族怪兽作为特殊召唤对象。
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24050692.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选中的怪兽以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
