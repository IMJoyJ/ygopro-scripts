--ダイスエット
-- 效果：
-- ①：掷1次骰子。发动回合的以下效果适用。
-- ●自己回合：从自己墓地选出现的数目数量的卡除外。出现的数目是1的场合，再从自己卡组上面把6张卡送去墓地。
-- ●对方回合：把出现的数目数量的卡从自己卡组上面送去墓地。出现的数目是6的场合，再选自己墓地1张卡除外。
function c8868767.initial_effect(c)
	-- ①：掷1次骰子。发动回合的以下效果适用。●自己回合：从自己墓地选出现的数目数量的卡除外。出现的数目是1的场合，再从自己卡组上面把6张卡送去墓地。●对方回合：把出现的数目数量的卡从自己卡组上面送去墓地。出现的数目是6的场合，再选自己墓地1张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_DECKDES+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c8868767.target)
	e1:SetOperation(c8868767.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标合法性检测与操作信息设置
function c8868767.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前是否为自己回合
	if Duel.GetTurnPlayer()==tp then
		-- 自己回合发动时，检查自己墓地是否存在至少1张可以除外的卡
		if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil) end
		-- 自己回合发动时，设置除外自己墓地卡片的操作信息
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_GRAVE)
	else
		-- 对方回合发动时，检查自己是否能将至少1张卡从卡组送去墓地
		if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
		-- 对方回合发动时，设置将卡组卡片送去墓地的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	end
end
-- 效果处理的执行函数
function c8868767.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 进行1次掷骰子，并记录出现的数目
	local d=Duel.TossDice(tp,1)
	-- 判断当前是否为自己回合
	if Duel.GetTurnPlayer()==tp then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己墓地选择与骰子数目相同数量的、且不受王家长眠之谷影响的可以除外的卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,d,d,nil)
		if g:GetCount()>0 then
			-- 将选中的卡片表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
		if d==1 then
			-- 将自己卡组上面6张卡送去墓地
			Duel.DiscardDeck(tp,6,REASON_EFFECT)
		end
	else
		-- 将自己卡组上面与骰子数目相同数量的卡送去墓地
		Duel.DiscardDeck(tp,d,REASON_EFFECT)
		if d==6 then
			-- 从自己墓地选择1张不受王家长眠之谷影响的可以除外的卡
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选中的1张卡表侧表示除外
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
