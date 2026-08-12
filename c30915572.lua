--星見獣ガリス
-- 效果：
-- 把手卡的这张卡给对方观看发动。自己卡组最上面的卡送去墓地，那张卡是怪兽的场合，给与对方基本分那只怪兽的等级×200的数值的伤害并把这张卡特殊召唤。那张卡是怪兽以外的场合，这张卡破坏。
function c30915572.initial_effect(c)
	-- 创建效果，设置效果描述为“卡组最上面的卡送去墓地”，设置效果类别为特殊召唤+伤害+卡组送去墓地，设置效果类型为起动效果，设置效果适用范围为手卡，设置效果费用为c30915572.spcost，设置效果目标为c30915572.sptarget，设置效果处理为c30915572.spoperation
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
-- 费用检查：确认手卡的这张卡未公开
function c30915572.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 目标检查：确认玩家可以将卡组最上面的1张卡送去墓地，场上怪兽区有空位，且这张卡可以被特殊召唤
function c30915572.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以将卡组最上面的1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查玩家场上怪兽区是否有空位且这张卡可以被特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将卡组最上面的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
-- 效果处理函数：将卡组最上面的卡送去墓地，根据送去墓地的卡是否为怪兽决定后续处理
function c30915572.spoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将玩家卡组最上面的1张卡送去墓地
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	-- 获取刚刚被送去墓地的卡组
	local g=Duel.GetOperatedGroup()
	local tc=g:GetFirst()
	if tc then
		-- 中断当前效果处理，使之后的效果视为错时处理
		Duel.BreakEffect()
		if tc:IsType(TYPE_MONSTER) then
			-- 对对方造成伤害，伤害值为送去墓地的卡的等级乘以200
			Duel.Damage(1-tp,tc:GetLevel()*200,REASON_EFFECT)
			if not c:IsRelateToEffect(e) then return end
			-- 将这张卡特殊召唤到自己场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 如果这张卡还在场上，则将其破坏
			if c:IsRelateToEffect(e) then Duel.Destroy(c,REASON_EFFECT) end
		end
	end
end
