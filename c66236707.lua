--械刀婪魔皇断
-- 效果：
-- 这张卡的发动和效果不会被无效化。
-- ①：自己的主要阶段1·主要阶段2的开始时，以场上的表侧表示卡任意数量为对象才能发动。作为对象的卡每有1张，自己1张手卡或自己的额外卡组6张卡里侧除外。那之后，作为对象的卡回到手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 这张卡的发动和效果不会被无效化。①：自己的主要阶段1·主要阶段2的开始时，以场上的表侧表示卡任意数量为对象才能发动。作为对象的卡每有1张，自己1张手卡或自己的额外卡组6张卡里侧除外。那之后，作为对象的卡回到手卡。
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
-- 定义发动条件函数，限制在自己的主要阶段1或主要阶段2的开始时发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
		-- 检查当前是否处于主要阶段。
		and Duel.IsMainPhase()
		-- 检查当前阶段是否尚未进行任何操作（即阶段开始时）。
		and not Duel.CheckPhaseActivity()
end
-- 过滤自身手牌或额外卡组中可以里侧除外的卡片。
function s.cfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 过滤场上表侧表示且可以回到手牌的卡片。
function s.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 定义效果的发动准备与对象选择函数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.tgfilter(chkc) end
	-- 计算自己手牌数量与额外卡组数量折算后的最大可选择对象数量（1张手牌或6张额外卡组折算为1个对象额度）。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_HAND,0,e:GetHandler(),tp)+math.floor(Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_EXTRA,0,nil,tp)/6)
	-- 在发动检查阶段，确认是否存在可选择的场上表侧表示卡，且自己有足够的卡片可以用于里侧除外。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 在客户端提示玩家选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择任意数量（不超过最大可除外折算数）的场上表侧表示卡作为效果的对象。
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler())
	-- 设置效果处理信息，表明此效果包含将选定对象送回手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 定义辅助函数，计算传入卡片组折算后的除外额度（手牌数 + 额外卡组数/6）。
function s.getct(g)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)+g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)/6
end
-- 定义效果处理函数，执行里侧除外和返回手牌的操作。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 获取自己手牌和额外卡组中可以被里侧除外的卡片组。
		local tg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,nil,tp)
		local ct=s.getct(tg)
		if ct>=g:GetCount() then
			-- 在客户端提示玩家选择要里侧除外的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local sg=s.selgroup(tg,tp,g:GetCount())
			-- 将选中的卡片里侧除外，并检查是否成功除外。
			if sg:GetCount()>0 and Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT) then
				-- 中断当前效果处理，使后续的“回到手牌”处理不与“里侧除外”同时进行（造成错时点）。
				Duel.BreakEffect()
				-- 将作为对象的卡片送回持有者的手牌。
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			end
		end
	end
end
-- 定义权值函数，用于SelectWithSumEqual：手牌卡片权值为6，额外卡组卡片权值为1。
function s.selgroup_count(c)
	if c:IsLocation(LOCATION_HAND) then
		return 6
	else
		return 1
	end
end
-- 定义辅助函数，用于精确选择总权值等于“对象数量 * 6”的卡片组合（1张手牌=6，6张额外=6）。
function s.selgroup(g,tp,ct)
	return g:SelectWithSumEqual(tp,s.selgroup_count,ct*6,1,#g)
end
