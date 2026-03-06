--溟界の呼び蛟
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：在自己场上把2只「溟界衍生物」（爬虫类族·暗·2星·攻/守0）特殊召唤。自己墓地有「溟界」怪兽8种类以上存在的场合，可以作为代替让以下效果适用。
-- ●从自己墓地选2只卡名不同的爬虫类族怪兽特殊召唤。
function c23837054.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,23837054+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c23837054.target)
	e1:SetOperation(c23837054.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤出满足条件的爬虫类族怪兽，可用于特殊召唤。
function c23837054.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：过滤出墓地中的溟界怪兽。
function c23837054.cfilter(c)
	return c:IsSetCard(0x161) and c:IsType(TYPE_MONSTER)
end
-- 效果作用：判断是否可以发动此卡效果，包括召唤衍生物或从墓地特殊召唤符合条件的怪兽。
function c23837054.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		-- 效果作用：获取墓地中所有溟界怪兽的集合。
		local cg=Duel.GetMatchingGroup(c23837054.cfilter,tp,LOCATION_GRAVE,0,nil)
		-- 效果作用：获取墓地中所有爬虫类族怪兽的集合。
		local tg=Duel.GetMatchingGroup(c23837054.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 效果作用：判断玩家是否可以特殊召唤溟界衍生物。
		return Duel.IsPlayerCanSpecialSummonMonster(tp,23837055,0,TYPES_TOKEN_MONSTER,0,0,2,RACE_REPTILE,ATTRIBUTE_DARK)
			or cg:GetClassCount(Card.GetCode)>=8 and tg:GetClassCount(Card.GetCode)>=2
	end
	-- 效果作用：设置操作信息，表示将特殊召唤2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 效果作用：设置操作信息，表示将特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果原文内容：①：在自己场上把2只「溟界衍生物」（爬虫类族·暗·2星·攻/守0）特殊召唤。自己墓地有「溟界」怪兽8种类以上存在的场合，可以作为代替让以下效果适用。
function c23837054.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果作用：检查玩家场上是否有足够的空间召唤怪兽。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 效果作用：获取墓地中所有溟界怪兽的集合。
	local cg=Duel.GetMatchingGroup(c23837054.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 效果作用：获取墓地中所有爬虫类族怪兽的集合（排除王家长眠之谷影响）。
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c23837054.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 效果作用：判断玩家是否可以特殊召唤溟界衍生物。
	local res1=Duel.IsPlayerCanSpecialSummonMonster(tp,23837055,0,TYPES_TOKEN_MONSTER,0,0,2,RACE_REPTILE,ATTRIBUTE_DARK)
	local res2=cg:GetClassCount(Card.GetCode)>=8 and tg:GetClassCount(Card.GetCode)>=2
	-- 效果作用：根据条件选择是否从墓地特殊召唤怪兽。
	if res2 and (not res1 or Duel.SelectYesNo(tp,aux.Stringid(23837054,0))) then  --"是否从墓地特殊召唤怪兽？"
		-- 效果作用：提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 效果作用：从符合条件的怪兽中选择2张卡名不同的怪兽。
		local sg=tg:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 效果作用：将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	elseif res1 then
		for i=1,2 do
			-- 效果作用：创建一张溟界衍生物。
			local token=Duel.CreateToken(tp,23837055)
			-- 效果作用：将一张溟界衍生物特殊召唤到场上。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 效果作用：完成所有特殊召唤步骤。
		Duel.SpecialSummonComplete()
	end
end
