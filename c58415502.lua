--ロイヤル・ストレート
-- 效果：
-- ①：从手卡以及自己场上的表侧表示怪兽之中选「王后骑士」「卫兵骑士」「国王骑士」各1只送去墓地。那之后，从自己的手卡·卡组·额外卡组·墓地选有「王后骑士」「卫兵骑士」「国王骑士」的卡名全部记述的1只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含关联卡名注册和①效果的注册
function s.initial_effect(c)
	-- 在卡片中注册关联卡名「王后骑士」、「卫兵骑士」和「国王骑士」
	aux.AddCodeList(c,25652259,64788463,90876561)
	-- ①：从手卡以及自己场上的表侧表示怪兽之中选「王后骑士」「卫兵骑士」「国王骑士」各1只送去墓地。那之后，从自己的手卡·卡组·额外卡组·墓地选有「王后骑士」「卫兵骑士」「国王骑士」的卡名全部记述的1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡或场上表侧表示的「王后骑士」、「卫兵骑士」或「国王骑士」且能送去墓地的卡
function s.tgfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCode(25652259,64788463,90876561) and c:IsAbleToGrave()
end
-- 过滤手卡、卡组、额外卡组、墓地中记述了「王后骑士」「卫兵骑士」「国王骑士」全部卡名，且在指定卡片送墓后能够特殊召唤的怪兽
function s.spfilter(c,e,tp,g)
	-- 检查怪兽的效果文本中是否全部记述了「王后骑士」、「卫兵骑士」和「国王骑士」的卡名
	if not (aux.IsCodeListed(c,25652259) and aux.IsCodeListed(c,64788463) and aux.IsCodeListed(c,90876561)) then return false end
	local proc=c:IsCode(11020863) and e:GetHandler():IsCode(id)
	if not c:IsCanBeSpecialSummoned(e,0,tp,proc,proc) then return false end
	-- 若特殊召唤的怪兽不在额外卡组，检查在选定的送墓卡片离场后，是否有可用的主怪兽区域
	return (not c:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp,g)>0
		-- 若特殊召唤的怪兽在额外卡组，检查在选定的送墓卡片离场后，是否有可用的额外怪兽区域
		or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,g,c)>0)
end
-- 检查选定的3张卡是否卡名各不相同，且此时是否存在可特殊召唤的合法怪兽
function s.fgoal(g,e,tp)
	-- 检查卡片组内卡名各不相同，且存在可特殊召唤的记述了三骑士卡名的怪兽
	return aux.dncheck(g) and Duel.IsExistingMatchingCard(s.spfilter,tp,
		LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,g)
end
-- 效果发动时的目标选择与合法性检测函数，声明送去墓地和特殊召唤的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡及自己场上表侧表示的「王后骑士」、「卫兵骑士」、「国王骑士」卡片组
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	if chk==0 then return g:CheckSubGroup(s.fgoal,3,3,e,tp) end
	-- 设置送去墓地的操作信息，预计将手卡或怪兽区的3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_HAND+LOCATION_MZONE)
	-- 设置特殊召唤的操作信息，预计从手卡、卡组、额外卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,
		LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 效果处理函数，执行将三骑士送去墓地并特殊召唤特定怪兽的操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前手卡及自己场上表侧表示的「王后骑士」、「卫兵骑士」、「国王骑士」卡片组
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择3张卡名各不相同的卡
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 将选中的3张卡送去墓地，并确认这3张卡都成功送入墓地
	if sg and Duel.SendtoGrave(sg,REASON_EFFECT)>0 and sg:IsExists(Card.IsLocation,3,nil,LOCATION_GRAVE) then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡、卡组、额外卡组、墓地中选择1只满足特殊召唤条件且不受「王家长眠之谷」影响的怪兽
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,
			LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp,nil):GetFirst()
		if tc then
			-- 中断当前效果处理，使后续的特殊召唤处理与送去墓地不视为同时进行
			Duel.BreakEffect()
			local proc=tc:IsCode(11020863) and e:GetHandler():IsCode(id)
			-- 将选中的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,proc,proc,POS_FACEUP)
			if proc then tc:CompleteProcedure() end
		end
	end
end
