--械刀婪魔皇断
-- 效果：
-- 这张卡的发动和效果不会被无效化。
-- ①：自己的主要阶段1·主要阶段2的开始时，以场上的表侧表示卡任意数量为对象才能发动。作为对象的卡每有1张，自己1张手卡或自己的额外卡组6张卡里侧除外。那之后，作为对象的卡回到手卡。
local s,id,o=GetID()
-- 初始化效果注册，设置该卡发动及效果不会被无效等属性
function s.initial_effect(c)
	-- 这张卡的发动和效果不会被无效化。①：自己的主要阶段1·主要阶段2 of 开始时，以场上的表侧表示卡任意数量为对象才能发动。作为对象的卡每有1张，自己1张手卡或自己的额外卡组6张卡里侧除外。那之后，作为对象的卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的条件检查：自己回合的主要阶段1或主要阶段2开始时
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否是自己的回合
	return Duel.GetTurnPlayer()==tp
		-- 检查当前是否处于主要阶段
		and Duel.IsMainPhase()
		-- 检查当前阶段是否还未进行过其他非特殊动作（阶段开始时）
		and not Duel.CheckPhaseActivity()
end
-- 过滤条件：可以里侧表示除外的卡片
function s.cfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 过滤条件：场上表侧表示且能回到手牌的卡片
function s.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果的发动阶段处理（计算可除外数、选择对象并设置连锁信息）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.tgfilter(chkc) end
	-- 计算手牌（每张计1）与额外卡组（每6张计1）可里侧除外的卡片总折合数
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_HAND,0,e:GetHandler(),tp)+math.floor(Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_EXTRA,0,nil,tp)/6)
	-- 检查可除外数量是否大于0，且场上是否存在可回到手牌的表侧表示卡片
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上表侧表示的卡片作为效果对象（数量不超过最大可除外数）
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler())
	-- 设置回到手牌的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 辅助函数：根据输入的卡片组计算其折合出的里侧除外权重数
function s.getct(g)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)+g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)/6
end
-- 效果的处理阶段，执行里侧除外并使对象卡片回到手牌的具体逻辑
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取依然与此效果关联的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 获取自己手牌及额外卡组中所有可以被里侧除外的卡片
		local tg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,nil,tp)
		local ct=s.getct(tg)
		if ct>=g:GetCount() then
			-- 提示玩家选择要除外的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local sg=s.selgroup(tg,tp,g:GetCount())
			-- 如果成功将所选的卡片里侧除外
			if sg:GetCount()>0 and Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)>0 then
				-- 中断当前效果，使之后的处理视为不同时处理
				Duel.BreakEffect()
				-- 将作为对象的场上卡片送回手牌
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			end
		end
	end
end
-- 辅助函数：设定混合选卡时手牌的权重为6，额外卡组卡片的权重为1
function s.selgroup_count(c)
	if c:IsLocation(LOCATION_HAND) then
		return 6
	else
		return 1
	end
end
-- 辅助函数：让玩家选择刚好能折合成对象卡片数量的除外卡片组
function s.selgroup(g,tp,ct)
	return g:SelectWithSumEqual(tp,s.selgroup_count,ct*6,1,#g)
end
