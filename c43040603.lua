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
-- 定义解放候选怪兽的过滤函数：用于选择代价解放的怪兽，只有解放该怪兽后我方场上仍有可用怪兽区空格时才允许选择。
function c43040603.cfilter(c,tp)
	-- 判定解放怪兽c后玩家tp场上可用怪兽区数量大于0，确保为后续特殊召唤留出格子。
	return Duel.GetMZoneCount(tp,c)>0
end
-- 代价处理函数：执行‘把自己场上1只怪兽解放’这一代价；将e的标签设为1以标记已支付代价，并选择1只满足条件的怪兽解放。
function c43040603.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 发动合法性检查：确认场上存在至少1只可解放的怪兽（解放后仍有空格），否则不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c43040603.cfilter,1,nil,tp) end
	-- 让玩家从自己场上选择1只满足条件的怪兽作为发动代价的解放对象。
	local g=Duel.SelectReleaseGroup(tp,c43040603.cfilter,1,1,nil,tp)
	-- 将选择的怪兽解放，解放原因记为代价（REASON_COST），完成怪兽之门的解放代价。
	Duel.Release(g,REASON_COST)
end
-- 目标设定函数：判断发动时是否满足特殊召唤条件——已通过解放腾出格子或场上本来有空格、玩家可以特殊召唤、卡组存在可通常召唤的怪兽且能翻卡，并登记操作信息。
function c43040603.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- res为真表示已有可供特殊召唤的怪兽区：若cost已把怪兽解放（Label为1），则因腾出格子而满足；否则要求当前场上已有空位。
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 返回条件之一：玩家可以进行特殊召唤，且没有受到‘元素英雄 烈焰侠’的不能特殊召唤非融合怪兽效果影响，也没有受到‘龙辉巧-右枢α’的只能特殊召唤不能通常召唤的怪兽效果影响。
		return res and Duel.IsPlayerCanSpecialSummon(tp) and not Duel.IsPlayerAffectedByEffect(tp,63060238) and not Duel.IsPlayerAffectedByEffect(tp,97148796)
			-- 返回条件之二：卡组中存在可以通常召唤的怪兽（作为翻卡停止对象），且玩家具备从卡组顶端把卡送去墓地（翻卡动作）的能力。
			and Duel.IsExistingMatchingCard(Card.IsSummonableCard,tp,LOCATION_DECK,0,1,nil) and Duel.IsPlayerCanDiscardDeck(tp,1)
	end
	-- 向系统登记本连锁将进行1次从卡组的特殊召唤，目标对象不定，为后续时点检测和效果互动提供信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果处理：从卡组顶按顺序翻卡，直到出现可以通常召唤的怪兽；若有，则在有空格且可特殊召唤时将其特殊召唤，其余翻开的卡送去墓地；若没有可通常召唤的怪兽，则确认全部卡组后洗切并结束处理。
function c43040603.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认：玩家此刻仍可进行特殊召唤且仍可丢弃卡组顶端卡，否则终止处理。
	if not Duel.IsPlayerCanSpecialSummon(tp) or not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 取得卡组中所有可以通常召唤的怪兽的集合，用于找出从卡组顶开始第一只可作为停止条件的目标怪兽。
	local g=Duel.GetMatchingGroup(Card.IsSummonableCard,tp,LOCATION_DECK,0,nil)
	-- 记录当前卡组总张数，用于计算从卡组顶到目标怪兽之间需要翻开的卡数。
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
		-- 当卡组中没有可以通常召唤的怪兽时，确认卡组最上方全部卡后洗切卡组并结束处理，不进行特殊召唤。
		Duel.ConfirmDecktop(tp,dcount)
		-- 将卡组洗切，恢复卡组顺序（因为没有特定怪兽被特殊召唤，也没有把卡送墓）。
		Duel.ShuffleDeck(tp)
		return
	end
	-- 确认从卡组顶到目标怪兽为止的卡（dcount-seq张），即本次翻开的所有卡，让双方确认。
	Duel.ConfirmDecktop(tp,dcount-seq)
	-- 判断场上仍有可用怪兽区且目标怪兽可以被玩家tp用该效果特殊召唤（检查召唤条件和苏生限制），决定是否执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and spcard:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 关闭下一次操作的自动洗牌检查；因为按效果翻卡并取出特定卡后，卡组剩余部分不应被自动洗切。
		Duel.DisableShuffleCheck()
		-- 若翻开的就是目标怪兽这一张（目标位于卡组顶），直接将其表侧表示特殊召唤，没有剩余翻开的卡需要送去墓地。
		if dcount-seq==1 then Duel.SpecialSummon(spcard,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 存在多张翻开卡时，先将目标怪兽以特殊召唤步骤放入处理流程，等待与送墓操作一起完成。
			Duel.SpecialSummonStep(spcard,0,tp,tp,false,false,POS_FACEUP)
			-- 将目标怪兽上方（更靠近卡组顶）的其余翻开卡从卡组顶端送去墓地，实现‘剩下的翻开的卡全部送去墓地’。
			Duel.DiscardDeck(tp,dcount-seq-1,REASON_EFFECT)
			-- 结束特殊召唤步骤，统一处理此前SpecialSummonStep的特殊召唤，确认特殊召唤成功。
			Duel.SpecialSummonComplete()
		end
	else
		-- 若目标怪兽无法特殊召唤，则将本次翻开的所有卡（包括目标怪兽在内）全部送去墓地。
		Duel.DiscardDeck(tp,dcount-seq,REASON_EFFECT)
	end
end
