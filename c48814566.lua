--魔獣の大餌
-- 效果：
-- ①：自己的额外卡组的卡任意数量里侧表示除外，对方的额外卡组的里侧表示的卡随机选那个数量直到结束阶段表侧表示除外。
function c48814566.initial_effect(c)
	-- ①：自己的额外卡组的卡任意数量里侧表示除外，对方的额外卡组的里侧表示的卡随机选那个数量直到结束阶段表侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c48814566.target)
	e1:SetOperation(c48814566.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：对方额外卡组里侧表示且可以被除外的卡
function c48814566.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- 效果发动的可行性检查与操作信息设置
function c48814566.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在可以里侧表示除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,1,nil,tp,POS_FACEDOWN)
		-- 检查对方额外卡组是否存在可以除外的里侧表示的卡
		and Duel.IsExistingMatchingCard(c48814566.rmfilter,tp,0,LOCATION_EXTRA,1,nil) end
	-- 设置操作信息：除外双方额外卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_EXTRA)
end
-- 效果处理：除外自己额外卡组的卡，并随机除外对方等量额外卡组的卡，注册结束阶段归还的效果
function c48814566.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己额外卡组可以里侧表示除外的卡片组
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,nil,tp,POS_FACEDOWN)
	-- 获取对方额外卡组可以除外的里侧表示卡片组
	local g2=Duel.GetMatchingGroup(c48814566.rmfilter,tp,0,LOCATION_EXTRA,nil)
	if #g1>0 and #g2>0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg1=g1:Select(tp,1,#g2,nil)
		-- 将选中的自己额外卡组的卡里侧表示除外，并确认是否成功除外
		if Duel.Remove(sg1,POS_FACEDOWN,REASON_EFFECT)~=0 and sg1:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
			-- 获取实际被除外的自己额外卡组的卡片组
			local og1=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
			-- 洗切对方的额外卡组
			Duel.ShuffleExtra(1-tp)
			local sg2=g2:RandomSelect(tp,#og1)
			-- 将随机选出的对方额外卡组的卡暂时表侧表示除外，并确认是否成功除外
			if Duel.Remove(sg2,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 and sg2:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
				local c=e:GetHandler()
				-- 获取实际被除外的对方额外卡组的卡片组
				local og2=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
				local tc=og2:GetFirst()
				while tc do
					tc:RegisterFlagEffect(48814566,RESET_EVENT+RESETS_STANDARD,0,1)
					tc=og2:GetNext()
				end
				og2:KeepAlive()
				-- 直到结束阶段表侧表示除外
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetLabelObject(og2)
				e1:SetCountLimit(1)
				e1:SetCondition(c48814566.retcon)
				e1:SetOperation(c48814566.retop)
				-- 注册在结束阶段将卡片归还额外卡组的延迟效果
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
-- 过滤条件：带有此卡效果标记的卡
function c48814566.retfilter(c)
	return c:GetFlagEffect(48814566)~=0
end
-- 检查是否存在带有标记的、需要归还的卡
function c48814566.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():IsExists(c48814566.retfilter,1,nil)
end
-- 在结束阶段将暂时除外的对方额外卡组的卡归还并洗切额外卡组
function c48814566.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c48814566.retfilter,nil,e:GetLabel())
	-- 将被除外的卡送回额外卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	g:DeleteGroup()
end
