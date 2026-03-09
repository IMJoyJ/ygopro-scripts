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
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c48814566.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- 效果作用
function c48814566.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索满足条件的卡片组
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,1,nil,tp,POS_FACEDOWN)
		-- 检索满足条件的卡片组
		and Duel.IsExistingMatchingCard(c48814566.rmfilter,tp,0,LOCATION_EXTRA,1,nil) end
	-- 设置当前处理的连锁的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_EXTRA)
end
-- 效果作用
function c48814566.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的卡片组
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,nil,tp,POS_FACEDOWN)
	-- 检索满足条件的卡片组
	local g2=Duel.GetMatchingGroup(c48814566.rmfilter,tp,0,LOCATION_EXTRA,nil)
	if #g1>0 and #g2>0 then
		-- 给玩家发送提示消息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg1=g1:Select(tp,1,#g2,nil)
		-- 将目标怪兽特殊召唤
		if Duel.Remove(sg1,POS_FACEDOWN,REASON_EFFECT)~=0 and sg1:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
			-- 获取之前一次卡片操作实际操作的卡片组
			local og1=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
			-- 手动洗切玩家额外卡组
			Duel.ShuffleExtra(1-tp)
			local sg2=g2:RandomSelect(tp,#og1)
			-- 将目标怪兽特殊召唤
			if Duel.Remove(sg2,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 and sg2:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
				local c=e:GetHandler()
				-- 获取之前一次卡片操作实际操作的卡片组
				local og2=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
				local tc=og2:GetFirst()
				while tc do
					tc:RegisterFlagEffect(48814566,RESET_EVENT+RESETS_STANDARD,0,1)
					tc=og2:GetNext()
				end
				og2:KeepAlive()
				-- ①：自己的额外卡组的卡任意数量里侧表示除外，对方的额外卡组的里侧表示的卡随机选那个数量直到结束阶段表侧表示除外。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetLabelObject(og2)
				e1:SetCountLimit(1)
				e1:SetCondition(c48814566.retcon)
				e1:SetOperation(c48814566.retop)
				-- 把效果作为玩家的效果注册给全局环境
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c48814566.retfilter(c)
	return c:GetFlagEffect(48814566)~=0
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c48814566.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():IsExists(c48814566.retfilter,1,nil)
end
-- 将目标怪兽特殊召唤
function c48814566.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c48814566.retfilter,nil,e:GetLabel())
	-- 将目标怪兽特殊召唤
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	g:DeleteGroup()
end
