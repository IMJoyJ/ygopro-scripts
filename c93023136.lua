--闇に堕ちた天使
-- 效果：
-- 这个卡名在规则上也当作「堕天使」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上（表侧表示）把1只天使族怪兽送去墓地才能发动。自己的手卡·卡组·除外状态的1只「堕天使」怪兽无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，定义①效果的魔陷发动效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·场上（表侧表示）把1只天使族怪兽送去墓地才能发动。自己的手卡·卡组·除外状态的1只「堕天使」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤作为发动代价送去墓地的手卡·场上天使族怪兽的条件函数
function s.costfilter(c,e,tp)
	-- 检查卡片是否为天使族怪兽、能否作为代价送去墓地、送去墓地后是否能腾出怪兽区域空格，且在场上时必须是表侧表示
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FAIRY) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0 and c:IsFaceupEx()
		-- 检查手卡、卡组、除外状态是否存在至少1只可以特殊召唤的「堕天使」怪兽（排除自身作为代价的卡）
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED,0,1,c,e,tp)
end
-- 过滤手卡、卡组、除外状态中可以无视召唤条件特殊召唤的「堕天使」怪兽的条件函数
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0xef) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果发动的代价处理函数
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查是否存在可作为代价送去墓地的天使族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或怪兽区选择1只满足条件的天使族怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动时的目标确认与操作信息设置函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:IsCostChecked() then
			return true
		else
			-- 检查自己场上是否有空余的怪兽区域
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 检查手卡、卡组、除外状态是否存在可以特殊召唤的「堕天使」怪兽
				and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp)
		end
	end
	-- 设置特殊召唤的操作信息，表明此效果包含从手卡、卡组、除外状态特殊召唤1只怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_REMOVED)
end
-- 效果处理（运行）函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、除外状态选择1只满足条件的「堕天使」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽无视召唤条件表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
