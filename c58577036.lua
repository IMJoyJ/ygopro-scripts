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
-- 检查发动条件：自己场上有怪兽区域空位、可以特殊召唤、不受特定限制卡片效果影响、卡组存在可以通常召唤的怪兽且可以把卡组顶端的卡送去墓地
function c58577036.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤，且未受到封锁特殊召唤或送去墓地等特定卡片效果的影响
		and Duel.IsPlayerCanSpecialSummon(tp) and not Duel.IsPlayerAffectedByEffect(tp,63060238) and not Duel.IsPlayerAffectedByEffect(tp,97148796)
		-- 检查自己卡组是否存在至少1张可以通常召唤的怪兽，且玩家可以把卡组顶端的卡送去墓地
		and Duel.IsExistingMatchingCard(Card.IsSummonableCard,tp,LOCATION_DECK,0,1,nil) and Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 设置当前连锁的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 执行效果处理：对方宣言等级，翻开卡组直到出现可以通常召唤的怪兽，若等级相同则全部送去墓地，若不同则特殊召唤该怪兽并将其余翻开的卡送去墓地
function c58577036.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若玩家不能特殊召唤或不能将卡组顶端的卡送去墓地，则不处理效果
	if not Duel.IsPlayerCanSpecialSummon(tp) or not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 向对方玩家发送提示信息，要求其宣言一个等级
	Duel.Hint(HINT_SELECTMSG,1-tp,HINGMSG_LVRANK)
	-- 让对方玩家宣言一个1至12的等级并获取该等级
	local lv=Duel.AnnounceLevel(1-tp)
	-- 获取自己卡组中所有可以通常召唤的怪兽卡组
	local g=Duel.GetMatchingGroup(Card.IsSummonableCard,tp,LOCATION_DECK,0,nil)
	-- 获取自己卡组中当前剩余的卡片总数
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
		-- 若卡组中没有可以通常召唤的怪兽，则确认自己卡组的全部卡片
		Duel.ConfirmDecktop(tp,dcount)
		-- 确认全部卡组后，将自己卡组洗牌
		Duel.ShuffleDeck(tp)
		return
	end
	-- 确认从卡组顶端开始直到那只可以通常召唤的怪兽为止的所有卡片
	Duel.ConfirmDecktop(tp,dcount-seq)
	-- 若自己场上有怪兽区域空位，且翻开的怪兽等级与对方宣言的等级不同
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not spcard:IsLevel(lv)
		and spcard:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 使接下来的操作不进行洗卡检测，防止因卡片离开卡组而自动洗牌
		Duel.DisableShuffleCheck()
		-- 如果翻开的第一张卡就是该怪兽（即不需要送去墓地其他卡），则直接将其表侧表示特殊召唤
		if dcount-seq==1 then Duel.SpecialSummon(spcard,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将该怪兽作为特殊召唤的步骤之一，准备表侧表示特殊召唤
			Duel.SpecialSummonStep(spcard,0,tp,tp,false,false,POS_FACEUP)
			-- 将该怪兽之前翻开的其他卡片全部送去墓地
			Duel.DiscardDeck(tp,dcount-seq-1,REASON_EFFECT)
			-- 完成该怪兽的特殊召唤处理
			Duel.SpecialSummonComplete()
		end
	else
		-- 若等级相同或无法特殊召唤，则将所有翻开的卡（包括该怪兽）全部送去墓地
		Duel.DiscardDeck(tp,dcount-seq,REASON_EFFECT+REASON_REVEAL)
	end
end
