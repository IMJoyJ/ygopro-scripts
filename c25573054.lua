--進化する翼
-- 效果：
-- 把自己场上存在的1只「羽翼栗子球」和2张手卡送到墓地。从手卡·卡组特殊召唤1只「羽翼栗子球 LV10」上场。
function c25573054.initial_effect(c)
	-- 把自己场上存在的1只「羽翼栗子球」和2张手卡送到墓地。从手卡·卡组特殊召唤1只「羽翼栗子球 LV10」上场。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetCost(c25573054.cost)
	e1:SetTarget(c25573054.target)
	e1:SetOperation(c25573054.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为代价送去墓地且卡名为「羽翼栗子球」（57116033）的卡。
function c25573054.tgfilter(c)
	return c:IsCode(57116033) and c:IsAbleToGraveAsCost()
end
-- 筛选卡名为「羽翼栗子球 LV10」（98585345）且能够被当前效果特殊召唤的候选卡。
function c25573054.spfilter(c,e,tp)
	return c:IsCode(98585345) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 代价处理：选择自己场上1只「羽翼栗子球」与2张手卡（若可特殊召唤的「羽翼栗子球 LV10」在卡组，手卡选2张；若其只存在于手卡，需绕过该候选选择2张其他手卡）送去墓地，作为发动此卡的代价。
function c25573054.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡·卡组中所有可以进行特殊召唤的「羽翼栗子球 LV10」的集合，用于判断代价数量及后续特殊召唤。
	local sg=Duel.GetMatchingGroup(c25573054.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 获取自己手牌中可以作为代价送去墓地的卡集合（排除进化之翼自身），用于选择2张手卡代价。
	local hg=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,e:GetHandler())
	if chk==0 then
		if sg:GetCount()==0 then return false end
		-- 查询自己主要怪兽区的可用空格数，用于决定从哪个区域选择「羽翼栗子球」以及能否特殊召唤。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<-1 then return false end
		if ft==0 then
			-- 当主要怪兽区无空位时，确认自己主要怪兽区存在至少1只可作为代价的「羽翼栗子球」，否则代价不合法。
			if not Duel.IsExistingMatchingCard(c25573054.tgfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
		else
			-- 当主要怪兽区有空位时，确认自己场上（主要怪兽区或魔法陷阱区）存在至少1只可作为代价的「羽翼栗子球」，否则代价不合法。
			if not Duel.IsExistingMatchingCard(c25573054.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) then return false end
		end
		if sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
			return hg:GetCount()>1
		else
			return hg:GetCount()>2
		end
	end
	local cg=nil
	-- 处理代价时重新获取主要怪兽区的可用空格数，以选择正确区域的「羽翼栗子球」。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft==0 then
		-- 提示玩家选择要送去墓地的卡，用于选择自己场上的「羽翼栗子球」作为代价。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 当主要怪兽区无空位时，从自己主要怪兽区选择1只「羽翼栗子球」作为送去墓地的代价。
		cg=Duel.SelectMatchingCard(tp,c25573054.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	else
		-- 提示玩家选择要送去墓地的卡，用于选择自己场上的「羽翼栗子球」作为代价。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 当主要怪兽区有空位时，从自己场上（主要怪兽区或魔法陷阱区）选择1只「羽翼栗子球」作为送去墓地的代价。
		cg=Duel.SelectMatchingCard(tp,c25573054.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	end
	local ct=sg:GetCount()
	if ct>2 or sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
		-- 提示玩家从手卡选择2张卡作为送去墓地的代价。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=hg:Select(tp,2,2,nil)
		cg:Merge(g)
	elseif ct==1 then
		-- 提示玩家从手卡选择2张卡作为送去墓地的代价，且不能选择唯一的「羽翼栗子球 LV10」候选。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=hg:Select(tp,2,2,sg:GetFirst())
		cg:Merge(g)
	else
		-- 提示玩家从手卡选择第1张作为送去墓地的代价。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g1=hg:Select(tp,1,1,nil)
		if sg:IsContains(g1:GetFirst()) then
			hg:Sub(sg)
		end
		-- 提示玩家从手卡选择第2张作为送去墓地的代价。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g2=hg:Select(tp,1,1,g1:GetFirst())
		cg:Merge(g1)
		cg:Merge(g2)
	end
	-- 将选中的「羽翼栗子球」和手卡作为发动代价送入墓地。
	Duel.SendtoGrave(cg,REASON_COST)
end
-- 效果发动时的目标处理：不取对象，合法则返回true，并登记本次特殊召唤的操作信息。
function c25573054.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次连锁的处理信息：将进行1只怪兽的特殊召唤，且特殊召唤的卡从手卡·卡组中选择（因不取对象，targets设为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理时实际执行特殊召唤：选择1只「羽翼栗子球 LV10」从手卡·卡组特殊召唤到自己场上，并调用CompleteProcedure完成其正规召唤手续。
function c25573054.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空位，则无法特殊召唤，直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己手卡·卡组选择1只符合条件的「羽翼栗子球 LV10」作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c25573054.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的「羽翼栗子球 LV10」以表侧表示特殊召唤到自己场上（不检查其召唤条件，苏生限制照常检查）。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
