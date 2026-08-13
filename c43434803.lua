--浅すぎた墓穴
-- 效果：
-- 双方玩家选择各自墓地1只怪兽在各自场上里侧守备表示盖放。
function c43434803.initial_effect(c)
	-- 双方玩家选择各自墓地1只怪兽在各自场上里侧守备表示盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c43434803.target)
	e1:SetOperation(c43434803.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断墓地中的怪兽是否可以被当前效果以里侧守备表示特殊召唤（检查召唤条件与苏生限制）。
function c43434803.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 发动时的目标处理：检查双方墓地是否存在能里侧守备特殊召唤的怪兽且双方主要怪兽区都有空位；随后让双方玩家各选自己墓地1只符合条件的怪兽作为对象，并登记特殊召唤的操作信息。
function c43434803.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		-- 检查己方墓地是否存在至少1只满足特殊召唤条件且能被取为对象的怪兽。
		return Duel.IsExistingTarget(c43434803.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			-- 检查自己场上是否有可用的主要怪兽区空格，确保能里侧守备盖放。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查对方墓地是否存在至少1只满足特殊召唤条件且能被取为对象的怪兽。
			and Duel.IsExistingTarget(c43434803.filter,1-tp,LOCATION_GRAVE,0,1,nil,e,1-tp)
			-- 检查对方场上是否有可用的主要怪兽区空格，确保对方也能里侧守备盖放。
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0
	end
	-- 向己方玩家发送选择提示，提示内容为‘请选择要特殊召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方玩家从己方墓地选择1只满足条件的怪兽，将其设为效果的对象。
	local sg=Duel.SelectTarget(tp,c43434803.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向对方玩家发送选择提示，提示内容为‘请选择要特殊召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让对方玩家从对方墓地选择1只满足条件的怪兽，将其设为效果的对象。
	local og=Duel.SelectTarget(1-tp,c43434803.filter,1-tp,LOCATION_GRAVE,0,1,1,nil,e,1-tp)
	local sc=sg:GetFirst()
	local oc=og:GetFirst()
	local g=Group.FromCards(sc,oc)
	-- 登记本次连锁的操作信息：将双方选择的怪兽（g中的2只）以特殊召唤的形式处理，用于后续效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
	e:SetLabelObject(sc)
end
-- 效果处理：从连锁对象中取出双方各选的怪兽，分别由原持有者以里侧守备表示特殊召唤到各自场上；若某只怪兽已不关联则跳过，最后完成特殊召唤。
function c43434803.operation(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	-- 获取当前连锁处理时的对象卡组（双方选择的两只怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local oc=g:GetFirst()
	if oc==sc then oc=g:GetNext() end
	if sc:IsRelateToEffect(e) then
		-- 将己方选择的怪兽以里侧守备表示特殊召唤到己方场上（检查召唤条件和苏生限制）。
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
	if oc:IsRelateToEffect(e) then
		-- 将对方选择的怪兽以里侧守备表示特殊召唤到对方场上（检查召唤条件和苏生限制）。
		Duel.SpecialSummonStep(oc,0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
	end
	-- 完成一连串特殊召唤处理（SpecialSummonStep 的收尾，统一处理召唤成功时的时点）。
	Duel.SpecialSummonComplete()
end
