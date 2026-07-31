--名推理
-- 效果：
-- ①：对方宣言1～12的任意等级。直到可以通常召唤的怪兽出现为止从自己卡组上面翻卡，那只怪兽的等级和宣言的等级相同的场合，翻开的卡全部送去墓地。不是的场合，那只怪兽特殊召唤，剩下的翻开的卡全部送去墓地。
function c58577036.initial_effect(c)
	-- ①：对方宣言1～12的任意等级。直到可以通常召唤的怪兽出现为止从自己卡组上面翻卡，那只怪兽的等级和宣言等级相同的场合，翻开的卡全部送去墓地。不是的场合，那只怪兽特殊召唤，剩下的翻开卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c58577036.target)
	e1:SetOperation(c58577036.operation)
	c:RegisterEffect(e1)
end
-- 特殊召唤效果准备：检查怪兽区域空位、特召与送墓限制及卡组通常召唤怪兽，并设置特召操作信息
function c58577036.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：玩家可进行特殊召唤且未受禁止特殊召唤/禁止翻卡的效果影响
		and Duel.IsPlayerCanSpecialSummon(tp) and not Duel.IsPlayerAffectedByEffect(tp,63060238) and not Duel.IsPlayerAffectedByEffect(tp,97148796)
		-- 发动条件检查：卡组存在可通常召唤的怪兽且玩家可将卡组的卡送去墓地
		and Duel.IsExistingMatchingCard(Card.IsSummonableCard,tp,LOCATION_DECK,0,1,nil) and Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 特殊召唤效果处理：对方宣言等级，翻开卡组直到出现可通常召唤怪兽，判断等级决定特召或全部送去墓地
function c58577036.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时玩家不能特殊召唤或不能堆墓，则终止效果处理
	if not Duel.IsPlayerCanSpecialSummon(tp) or not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 提示对方玩家宣言等级
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_LVRANK)
	-- 对方玩家宣言1~12的任意等级
	local lv=Duel.AnnounceLevel(1-tp)
	-- 获取卡组中所有可通常召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSummonableCard,tp,LOCATION_DECK,0,nil)
	-- 获取己方卡组的总张数
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
		-- 卡组中没有可通常召唤怪兽时，翻开确认全部卡组
		Duel.ConfirmDecktop(tp,dcount)
		-- 洗切卡组
		Duel.ShuffleDeck(tp)
		return
	end
	-- 从卡组上面翻卡，直到翻出第一只可通常召唤的怪兽
	Duel.ConfirmDecktop(tp,dcount-seq)
	-- 判断怪兽等级是否与对方宣言等级不同，且怪兽区域有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not spcard:IsLevel(lv)
		and spcard:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 禁用洗牌检查（避免翻卡过程触发自动洗牌）
		Duel.DisableShuffleCheck()
		-- 若翻出的第一张卡就是该怪兽，直接表侧表示特殊召唤
		if dcount-seq==1 then Duel.SpecialSummon(spcard,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将翻出的怪兽表侧表示特殊召唤（步骤1）
			Duel.SpecialSummonStep(spcard,0,tp,tp,false,false,POS_FACEUP)
			-- 将其前面翻出的非通常召唤怪兽卡全部送去墓地
			Duel.DiscardDeck(tp,dcount-seq-1,REASON_EFFECT)
			-- 完成特殊召唤流程
			Duel.SpecialSummonComplete()
		end
	else
		-- 若宣言等级相同或不能特召，将翻开的所有卡全部送去墓地
		Duel.DiscardDeck(tp,dcount-seq,REASON_EFFECT+REASON_REVEAL)
	end
end
