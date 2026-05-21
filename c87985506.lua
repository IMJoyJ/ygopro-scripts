--デーモンの諧謔
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡·卡组把1只7星以下的「恶魔」怪兽特殊召唤。自己的额外卡组有表侧的「恶魔」仪式怪兽存在的场合，也能作为代替把「王家恶魔」「公爵恶魔」「殿下恶魔」各最多1只从手卡·卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 将「王家恶魔」、「公爵恶魔」、「殿下恶魔」的卡名注册到本卡的关联卡片列表中。
	aux.AddCodeList(c,58769832,85154941,11248645)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡·卡组把1只7星以下的「恶魔」怪兽特殊召唤。自己的额外卡组有表侧的「恶魔」仪式怪兽存在的场合，也能作为代替把「王家恶魔」「公爵恶魔」「殿下恶魔」各最多1只从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡·卡组中可以特殊召唤的7星以下「恶魔」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x45) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：手卡·卡组中可以特殊召唤的「王家恶魔」、「公爵恶魔」、「殿下恶魔」。
function s.cspfilter(c,e,tp)
	return c:IsCode(58769832,85154941,11248645) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检查函数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在至少1只满足条件的7星以下「恶魔」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为：从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 过滤条件：额外卡组中表侧表示的「恶魔」仪式怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x45) and c:IsType(TYPE_RITUAL)
end
-- 效果处理（特殊召唤怪兽）的执行函数。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查是否可以进行常规的特殊召唤（7星以下「恶魔」怪兽）。
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
	-- 检查手卡·卡组中是否存在可以特殊召唤的「王家恶魔」、「公爵恶魔」或「殿下恶魔」。
	local b2=Duel.IsExistingMatchingCard(s.cspfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
		-- 检查额外卡组中是否存在表侧表示的「恶魔」仪式怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
	-- 如果满足代替特殊召唤的条件，且玩家选择进行代替特殊召唤（或者无法进行常规特殊召唤时强制进行代替特殊召唤）。
	if b2 and (not b1 or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then  --"是否作为代替特殊召唤最多3只怪兽？"
		-- 获取手卡·卡组中所有可特殊召唤的「王家恶魔」、「公爵恶魔」、「殿下恶魔」。
		local g=Duel.GetMatchingGroup(s.cspfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
		-- 获取自己场上可用的怪兽区域数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft>0 and #g>0 then
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家选择最多3张（且不超过可用怪兽区域数量）卡名各不相同的怪兽。
			local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(3,ft))
			if sg then
				-- 将选中的怪兽以表侧表示特殊召唤。
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif b1 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡·卡组选择1只满足条件的7星以下「恶魔」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的1只怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
