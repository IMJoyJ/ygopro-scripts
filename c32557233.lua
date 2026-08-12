--六花深々
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡也能把自己场上1只植物族怪兽解放来发动。
-- ①：从自己墓地选1只「六花」怪兽守备表示特殊召唤。把怪兽解放来把这张卡发动的场合，再从自己墓地选1只植物族怪兽守备表示特殊召唤。
function c32557233.initial_effect(c)
	-- ①：从自己墓地选1只「六花」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32557233,0))  --"不解放怪兽发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,32557233+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c32557233.target)
	e1:SetOperation(c32557233.activate)
	c:RegisterEffect(e1)
	-- 把怪兽解放来把这张卡发动的场合，再从自己墓地选1只植物族怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32557233,1))  --"解放怪兽发动"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,32557233+EFFECT_COUNT_CODE_OATH)
	e2:SetCost(c32557233.cost)
	e2:SetTarget(c32557233.target2)
	e2:SetOperation(c32557233.activate2)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地中的「六花」怪兽是否可以特殊召唤并满足后续条件
function c32557233.spfilter(c,e,tp,check)
	return c:IsSetCard(0x141) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 若check为假，则检查是否存在满足条件的植物族怪兽以确保能发动第二段效果
		and (check or Duel.IsExistingMatchingCard(c32557233.spfilter2,tp,LOCATION_GRAVE,0,1,c,e,tp))
end
-- 过滤函数，用于判断墓地中的植物族怪兽是否可以特殊召唤
function c32557233.spfilter2(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果的发动条件：检查是否有足够的怪兽区域和满足条件的「六花」怪兽
function c32557233.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家场上是否有足够的怪兽区域
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查玩家墓地是否存在满足条件的「六花」怪兽
			and Duel.IsExistingMatchingCard(c32557233.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,true)
	end
	-- 设置效果处理时的操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 设置效果的处理函数：从墓地选择并特殊召唤一只「六花」怪兽
function c32557233.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择满足条件的「六花」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32557233.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,true)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤函数，用于判断场上可解放的怪兽是否满足条件
function c32557233.rfilter(c,tp)
	-- 检查玩家场上是否有超过1个空怪兽区
	return Duel.GetMZoneCount(tp,c)>1 and (c:IsControler(tp) or c:IsFaceup())
		and (c:IsRace(RACE_PLANT) or c:IsHasEffect(76869711,tp) and c:IsControler(1-tp))
end
-- 设置效果的费用处理函数：选择并解放一只符合条件的怪兽
function c32557233.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查玩家场上是否存在满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c32557233.rfilter,1,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从场上选择满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c32557233.rfilter,1,1,nil,tp)
	-- 将选中的怪兽进行解放
	Duel.Release(g,REASON_COST)
end
-- 设置效果的发动条件：检查是否有足够的怪兽区域、满足条件的「六花」怪兽和特殊召唤次数限制
function c32557233.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否已通过解放怪兽发动过此卡或场上是否有足够怪兽区
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>1
	if chk==0 then
		e:SetLabel(0)
		return res and e:IsHasType(EFFECT_TYPE_ACTIVATE)
			-- 检查玩家墓地是否存在满足条件的「六花」怪兽
			and Duel.IsExistingMatchingCard(c32557233.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			-- 检查玩家是否还能特殊召唤2次
			and Duel.IsPlayerCanSpecialSummonCount(tp,2)
	end
	-- 设置效果处理时的操作信息，表示将要特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
-- 设置效果的处理函数：从墓地选择并特殊召唤一只「六花」怪兽，若已解放怪兽则再召唤一只植物族怪兽
function c32557233.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择满足条件的「六花」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32557233.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,true)
	local tc=g:GetFirst()
	-- 若成功特殊召唤了怪兽，则继续判断是否满足第二段效果的发动条件
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		if e:IsHasType(EFFECT_TYPE_ACTIVATE)
			-- 检查玩家场上是否有足够的怪兽区域
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查玩家墓地是否存在满足条件的植物族怪兽
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c32557233.spfilter2),tp,LOCATION_GRAVE,0,1,nil,e,tp) then
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从墓地中选择满足条件的植物族怪兽
			local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32557233.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			-- 将选中的植物族怪兽特殊召唤到场上
			Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
