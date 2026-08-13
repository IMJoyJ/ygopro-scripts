--名推理
-- 效果：
-- ①：对方宣言1～12的任意等级。直到可以通常召唤的怪兽出现为止从自己卡组上面翻卡，那只怪兽的等级和宣言的等级相同的场合，翻开的卡全部送去墓地。不是的场合，那只怪兽特殊召唤，剩下的翻开的卡全部送去墓地。
function c58577036.initial_effect(c)
	-- ①：对方宣言1～12的任意等级。直到可以通常召唤的怪兽出现为止从自己卡组上面翻卡，那只怪兽的等级和宣言的等级相同的场合，翻开的卡全部送去墓地。不是的场合，那只怪兽特殊召唤，剩下的翻开的卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c58577036.target)
	e1:SetOperation(c58577036.operation)
	c:RegisterEffect(e1)
end
-- 发动条件检测：确认自己主要怪兽区有空位、可以进行特殊召唤、不受限制宣言等级的卡的效果影响、卡组存在可以通常召唤的怪兽、且可以把卡组最上端的卡送去墓地
function c58577036.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己能否进行特殊召唤，且不受卡号63060238（催眠术）和97148796（等级限制B地区等）的效果影响
		and Duel.IsPlayerCanSpecialSummon(tp) and not Duel.IsPlayerAffectedByEffect(tp,63060238) and not Duel.IsPlayerAffectedByEffect(tp,97148796)
		-- 检查自己卡组存在至少1张可以通常召唤的怪兽，且可以把卡组最上端1张卡送去墓地
		and Duel.IsExistingMatchingCard(Card.IsSummonableCard,tp,LOCATION_DECK,0,1,nil) and Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 设置操作信息：此连锁预计从卡组特殊召唤1只怪兽（对象在处理时才能确定）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果处理：让对方宣言等级，从自己卡组最上方翻出直到出现可以通常召唤的怪兽为止；等级相同的场合全部送去墓地，不同的场合把那只怪兽特殊召唤并把其余翻开的卡送去墓地
function c58577036.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己可以进行特殊召唤且可以把卡组最上端1张卡送去墓地，否则中断处理
	if not Duel.IsPlayerCanSpecialSummon(tp) or not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 提示对方玩家选择要宣言的等级
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_LVRANK)
	-- 让对方宣言1～12的任意等级并记录下来
	local lv=Duel.AnnounceLevel(1-tp)
	-- 取出自己卡组中所有可以通常召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSummonableCard,tp,LOCATION_DECK,0,nil)
	-- 记录自己卡组的卡片数量
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
		-- 确认自己卡组最上方的全部卡（卡组中没有可通常召唤的怪兽时）
		Duel.ConfirmDecktop(tp,dcount)
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		return
	end
	-- 从自己卡组上面翻卡，直到可以通常召唤的怪兽出现为止
	Duel.ConfirmDecktop(tp,dcount-seq)
	-- 如果自己主要怪兽区有空位，且翻出的怪兽的等级和对方宣言的等级不同
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not spcard:IsLevel(lv)
		and spcard:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 使接下来的从卡组取出卡的操作不触发自动洗切卡组检测
		Duel.DisableShuffleCheck()
		-- 如果翻开的卡只有那1只怪兽，则把那只怪兽以正面表示特殊召唤
		if dcount-seq==1 then Duel.SpecialSummon(spcard,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 把翻出的那只怪兽以正面表示特殊召唤（分步特殊召唤的第一步）
			Duel.SpecialSummonStep(spcard,0,tp,tp,false,false,POS_FACEUP)
			-- 把其余翻开的卡全部送去墓地
			Duel.DiscardDeck(tp,dcount-seq-1,REASON_EFFECT)
			-- 完成分步特殊召唤
			Duel.SpecialSummonComplete()
		end
	else
		-- 那只怪兽的等级和宣言的等级相同的场合，把翻开的卡全部送去墓地
		Duel.DiscardDeck(tp,dcount-seq,REASON_EFFECT+REASON_REVEAL)
	end
end
