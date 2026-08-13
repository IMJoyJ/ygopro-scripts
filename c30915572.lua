--星見獣ガリス
-- 效果：
-- 把手卡的这张卡给对方观看发动。自己卡组最上面的卡送去墓地，那张卡是怪兽的场合，给与对方基本分那只怪兽的等级×200的数值的伤害并把这张卡特殊召唤。那张卡是怪兽以外的场合，这张卡破坏。
function c30915572.initial_effect(c)
	-- 把手卡的这张卡给对方观看发动。自己卡组最上面的卡送去墓地，那张卡是怪兽的场合，给与对方基本分那只怪兽的等级×200的数值的伤害并把这张卡特殊召唤。那张卡是怪兽以外的场合，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30915572,0))  --"卡组最上面的卡送去墓地"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c30915572.spcost)
	e1:SetTarget(c30915572.sptarget)
	e1:SetOperation(c30915572.spoperation)
	c:RegisterEffect(e1)
end
-- 作为发动代价，确认手牌的这张卡尚未公开（以便展示给对方观看），满足条件才能发动。
function c30915572.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 作为发动条件检查，确认自己卡组最上方1张卡能被送去墓地、自己主要怪兽区有空位、且这张卡能够特殊召唤，全部满足才可发动。
function c30915572.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以把卡组最上方1张卡送去墓地（即卡组有卡且没有禁止从卡组送墓的效果限制）。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查自己场上的主要怪兽区是否有可用的空格，以及这张卡是否满足特殊召唤条件（如苏生限制、召唤手续等）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本效果将把卡组最上方1张卡送去墓地的操作信息，便于其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
-- 效果处理的实现：先丢卡组顶端1张；若是怪兽，则给予对方其等级×200的伤害并特殊召唤这张卡；若不是怪兽，则破坏这张卡。
function c30915572.spoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 以效果原因将自己卡组最上方1张卡送去墓地。
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	-- 取得刚才因丢卡组而送入墓地的那些卡（实际为1张），用于判断其种类。
	local g=Duel.GetOperatedGroup()
	local tc=g:GetFirst()
	if tc then
		-- 中断当前效果处理，使之后的伤害/特殊召唤或破坏不与被送去墓地视为同一时点，以正确触发双方的效果。
		Duel.BreakEffect()
		if tc:IsType(TYPE_MONSTER) then
			-- 给予对方基本分那只怪兽的等级×200的数值的伤害。
			Duel.Damage(1-tp,tc:GetLevel()*200,REASON_EFFECT)
			if not c:IsRelateToEffect(e) then return end
			-- 将这张卡（星见兽 加里斯）以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 若这张卡仍与效果相关联（处理时未离场），则将其破坏。
			if c:IsRelateToEffect(e) then Duel.Destroy(c,REASON_EFFECT) end
		end
	end
end
