--督戦官コヴィントン
-- 效果：
-- ①：把自己场上的表侧表示的「机甲士兵」「机甲狙击兵」「机甲卫兵」各1只送去墓地才能发动。从手卡·卡组把1只「机甲部队·武装力量」特殊召唤。
function c22666164.initial_effect(c)
	-- ①：把自己场上的表侧表示的「机甲士兵」「机甲狙击兵」「机甲卫兵」各1只送去墓地才能发动。从手卡·卡组把1只「机甲部队·武装力量」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22666164,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c22666164.cost)
	e1:SetTarget(c22666164.target)
	e1:SetOperation(c22666164.operation)
	c:RegisterEffect(e1)
end
-- 为效果生成三个判定函数，分别检查卡是否为「机甲士兵」「机甲狙击兵」「机甲卫兵」的卡号，以便后续要求三种怪兽各1只作为代价。
c22666164.spchecks=aux.CreateChecks(Card.IsCode,{60999392,23782705,96384007})
-- 定义代价候选卡的过滤条件：必须是表侧表示、可以作为代价送去墓地、且卡号为三种机甲怪兽之一的卡。
function c22666164.spcostfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsCode(60999392,23782705,96384007)
end
-- 代价函数：从自己场上获取所有符合条件的三种机甲怪兽，在发动确认时验证能否各选择1只且送墓后仍有怪兽区空格；正式处理后提示玩家选择各类1只，并将它们作为代价送去墓地。
function c22666164.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有满足代价过滤条件（表侧表示、可为代价、是三种机甲怪兽之一）的卡，作为后续选择代价的候选组。
	local g=Duel.GetMatchingGroup(c22666164.spcostfilter,tp,LOCATION_MZONE,0,nil)
	-- 在发动合法性检查（chk==0）时，要求候选组能够选出「机甲士兵」「机甲狙击兵」「机甲卫兵」各1只，且将这些卡送去墓地后自己场上仍有可用的怪兽区域空位（用于后续特殊召唤）。
	if chk==0 then return g:CheckSubGroupEach(c22666164.spchecks,aux.mzctcheck,tp) end
	-- 向玩家发送选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从候选组中让玩家选择需要各1只、种类各不同的三种机甲怪兽（即「机甲士兵」「机甲狙击兵」「机甲卫兵」各1只）作为代价，并确保送墓后仍有怪兽区空格，返回所选的卡组 sg。
	local sg=g:SelectSubGroupEach(tp,c22666164.spchecks,false,aux.mzctcheck,tp)
	-- 将所选的三种机甲怪兽作为发动代价（REASON_COST）送去墓地。
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 定义特殊召唤目标的过滤条件：必须是要特殊召唤的「机甲部队·武装力量」（卡号58054262），并且可以被本次效果特殊召唤（不检查苏生限制）。
function c22666164.filter(c,e,tp)
	return c:IsCode(58054262) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
-- 目标函数：在发动时检查自己场上怪兽区空位是否足够（送墓3只后仍有空格），且手卡·卡组中是否存在至少1只符合条件的「机甲部队·武装力量」；若均满足则随后设置操作信息。
function c22666164.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：当前自己场上可用怪兽区数量需大于 -3，以保证即使代价三只怪兽占满了原有区域，送去墓地后也仍有至少1个怪兽区空位用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3
		-- 发动条件检查：手卡或卡组中必须存在至少1只满足过滤条件（卡号58054262且可被特殊召唤）的「机甲部队·武装力量」。
		and Duel.IsExistingMatchingCard(c22666164.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果的操作信息：效果分类为特殊召唤（CATEGORY_SPECIAL_SUMMON），预计从手卡·卡组特殊召唤1只卡，目标玩家为发动者 tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理函数：在效果处理时再次确认自己场上还有怪兽区空位，然后从手卡·卡组选择1只「机甲部队·武装力量」特殊召唤到自己场上，并补记其特殊召唤手续（CompleteProcedure），使其完成正规出场限制。
function c22666164.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己场上没有任何可用的怪兽区域空位，则特殊召唤不处理，直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己的手卡·卡组中选择1只满足 filter 条件的「机甲部队·武装力量」（卡号58054262且可被本次效果特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c22666164.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的1只「机甲部队·武装力量」以表侧攻击表示特殊召唤到自己场上（不检查苏生限制，因为该怪兽本应只能通过本卡效果特殊召唤）。
		Duel.SpecialSummon(g,0,tp,tp,false,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
