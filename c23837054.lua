--溟界の呼び蛟
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：在自己场上把2只「溟界衍生物」（爬虫类族·暗·2星·攻/守0）特殊召唤。自己墓地有「溟界」怪兽8种类以上存在的场合，可以作为代替让以下效果适用。
-- ●从自己墓地选2只卡名不同的爬虫类族怪兽特殊召唤。
function c23837054.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：在自己场上把2只「溟界衍生物」（爬虫类族·暗·2星·攻/守0）特殊召唤。自己墓地有「溟界」怪兽8种类以上存在的场合，可以作为代替让以下效果适用。●从自己墓地选2只卡名不同的爬虫类族怪兽特殊召唤。
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
-- 定义墓地爬虫类族怪兽的过滤函数：须为爬虫类族且能被当前效果特殊召唤（需满足召唤手续与苏生限制），用于发动判定和效果处理时选择可特召的怪兽。
function c23837054.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义「溟界」怪兽的过滤函数：卡名含0x161「溟界」字段且为怪兽卡，用于统计墓地中「溟界」怪兽的种类数。
function c23837054.cfilter(c)
	return c:IsSetCard(0x161) and c:IsType(TYPE_MONSTER)
end
-- 发动时的目标判定：若青眼精灵龙效果适用中或我方主怪兽区空位不足2个则不能发动；否则统计墓地「溟界」怪兽种类和可特招爬虫类怪兽种类，判断能否出衍生物或适用墓地替代效果，并写入对应的特殊召唤/衍生物操作信息。
function c23837054.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		-- 在发动判定中获取我方墓地的所有「溟界」怪兽组，用于计算是否达到8种类以上。
		local cg=Duel.GetMatchingGroup(c23837054.cfilter,tp,LOCATION_GRAVE,0,nil)
		-- 在发动判定中获取我方墓地可被当前效果特殊召唤的爬虫类族怪兽组，用于判断是否满足从墓地选2只卡名不同的怪兽特招的替代条件。
		local tg=Duel.GetMatchingGroup(c23837054.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 检查当前玩家是否能够将「溟界衍生物」（爬虫类族·暗·2星·攻/守0）特殊召唤，以确定正常衍生物路线是否可行。
		return Duel.IsPlayerCanSpecialSummonMonster(tp,23837055,0,TYPES_TOKEN_MONSTER,0,0,2,RACE_REPTILE,ATTRIBUTE_DARK)
			or cg:GetClassCount(Card.GetCode)>=8 and tg:GetClassCount(Card.GetCode)>=2
	end
	-- 设置本连锁将产生2只衍生物的操作信息（category含CATEGORY_TOKEN），供其他卡进行发动时点/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置本连锁将进行2只怪兽特殊召唤的操作信息（category含CATEGORY_SPECIAL_SUMMON），覆盖从墓地特招路线。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理：再次确认未受青眼精灵龙限制且主怪兽区有2个空位；获取墓地符合条件的「溟界」怪兽组与可特招爬虫类族怪兽组，分别判断衍生物路线和墓地替代路线；若墓地路线可行，则询问玩家是否选2只卡名不同的爬虫类族怪兽从墓地特招，否则在可行时生成2只衍生物。
function c23837054.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 主怪兽区可用空位不足2个时效果不处理，因为无论哪条路线都需要2个怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 在效果处理中获取我方墓地的所有「溟界」怪兽组，用于再次确认墓地「溟界」怪兽是否达到8种类以上。
	local cg=Duel.GetMatchingGroup(c23837054.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 在效果处理中获取我方墓地可被特殊召唤的爬虫类族怪兽组，并用NecroValleyFilter排除王家长眠之谷等影响墓地卡片效果的对象，作为替代特招的候选。
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c23837054.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检查当前玩家能否特殊召唤「溟界衍生物」，作为是否执行衍生物路线的依据。
	local res1=Duel.IsPlayerCanSpecialSummonMonster(tp,23837055,0,TYPES_TOKEN_MONSTER,0,0,2,RACE_REPTILE,ATTRIBUTE_DARK)
	local res2=cg:GetClassCount(Card.GetCode)>=8 and tg:GetClassCount(Card.GetCode)>=2
	-- 若墓地替代条件成立，且衍生物路线也可行时征求玩家是否选择替代效果；若只有墓地路线可行则直接适用替代效果。
	if res2 and (not res1 or Duel.SelectYesNo(tp,aux.Stringid(23837054,0))) then  --"是否从墓地特殊召唤怪兽？"
		-- 弹出选择提示消息，要求玩家从候选怪兽中选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从候选爬虫类族怪兽组中选择2张卡名不同的怪兽，作为从墓地特殊召唤的对象。
		local sg=tg:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选中的2只卡名不同的爬虫类族怪兽以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	elseif res1 then
		for i=1,2 do
			-- 生成1只卡号为23837055的「溟界衍生物」（爬虫类族·暗·2星·攻/守0）。
			local token=Duel.CreateToken(tp,23837055)
			-- 将生成的衍生物以表侧表示加入特殊召唤处理序列，连续调用两次以特殊召唤2只衍生物。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成分步特殊召唤处理，使2只衍生物正式特殊召唤到场上。
		Duel.SpecialSummonComplete()
	end
end
