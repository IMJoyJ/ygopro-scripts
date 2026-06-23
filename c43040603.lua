--モンスターゲート
-- 效果：
-- ①：把自己场上1只怪兽解放才能发动。直到可以通常召唤的怪兽出现为止从自己卡组上面翻卡，那只怪兽特殊召唤。剩下的翻开的卡全部送去墓地。
function c43040603.initial_effect(c)
	-- ①：把自己场上1只怪兽解放才能发动。直到可以通常召唤的怪兽出现为止从自己卡组上面翻卡，那只怪兽特殊召唤。剩下的翻开的卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c43040603.cost)
	e1:SetTarget(c43040603.target)
	e1:SetOperation(c43040603.operation)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在可以解放的怪兽
function c43040603.cfilter(c,tp)
	-- 返回场上可用怪兽区数量大于0
	return Duel.GetMZoneCount(tp,c)>0
end
-- 解放场上1只怪兽作为发动代价
function c43040603.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c43040603.cfilter,1,nil,tp) end
	-- 选择1只可解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,c43040603.cfilter,1,1,nil,tp)
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 设置效果发动的条件
function c43040603.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查玩家是否可以特殊召唤
		return res and Duel.IsPlayerCanSpecialSummon(tp) and not Duel.IsPlayerAffectedByEffect(tp,63060238) and not Duel.IsPlayerAffectedByEffect(tp,97148796)
			-- 检查卡组是否存在可通常召唤的怪兽且玩家可以将卡组最上方1张卡送去墓地
			and Duel.IsExistingMatchingCard(Card.IsSummonableCard,tp,LOCATION_DECK,0,1,nil) and Duel.IsPlayerCanDiscardDeck(tp,1)
	end
	-- 设置效果处理时要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 处理效果的发动
function c43040603.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以特殊召唤且卡组最上方是否可以送去墓地
	if not Duel.IsPlayerCanSpecialSummon(tp) or not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 获取卡组中所有可通常召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSummonableCard,tp,LOCATION_DECK,0,nil)
	-- 获取卡组中卡的数量
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local tc=g:GetFirst()
	local spcard=nil
	while tc do
		if tc:GetSequence()>seq then
			seq=tc:GetSequence()
			spcard=tc
		end
		tc=g:GetNext()
	end
	if seq==-1 then
		-- 确认卡组最上方所有卡
		Duel.ConfirmDecktop(tp,dcount)
		-- 将卡组洗切
		Duel.ShuffleDeck(tp)
		return
	end
	-- 确认卡组最上方至最后一只可通常召唤怪兽的卡
	Duel.ConfirmDecktop(tp,dcount-seq)
	-- 判断是否可以特殊召唤该怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and spcard:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 禁止后续操作自动洗切卡组
		Duel.DisableShuffleCheck()
		-- 若只翻开1张卡则直接特殊召唤
		if dcount-seq==1 then Duel.SpecialSummon(spcard,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 特殊召唤一张怪兽
			Duel.SpecialSummonStep(spcard,0,tp,tp,false,false,POS_FACEUP)
			-- 将剩余翻开的卡送去墓地
			Duel.DiscardDeck(tp,dcount-seq-1,REASON_EFFECT)
			-- 完成特殊召唤流程
			Duel.SpecialSummonComplete()
		end
	else
		-- 将剩余翻开的卡送去墓地
		Duel.DiscardDeck(tp,dcount-seq,REASON_EFFECT)
	end
end
