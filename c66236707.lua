--械刀婪魔皇断
-- 效果：
-- 这张卡的发动和效果不会被无效化。
-- ①：自己的主要阶段1·主要阶段2的开始时，以场上的表侧表示卡任意数量为对象才能发动。作为对象的卡每有1张，自己1张手卡或自己的额外卡组6张卡里侧除外。那之后，作为对象的卡回到手卡。
local s,id,o=GetID()
-- 初始化效果：创建魔陷发动类效果，设置提示文字、回手卡与除外的效果分类、自由时点、取对象且发动与效果不会被无效化（可被禁止令停止适用），并设定发动条件、对象选择与效果处理函数后注册到卡片
function s.initial_effect(c)
	-- 这张卡的发动和效果不会被无效化。①：自己的主要阶段1·主要阶段2的开始时，以场上的表侧表示卡任意数量为对象才能发动。
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
-- 发动条件：只有在自己回合的主要阶段开始时（阶段内尚未进行任何操作）才能发动
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家必须是自己
	return Duel.GetTurnPlayer()==tp
		-- 当前阶段必须是主要阶段（主要阶段1或主要阶段2）
		and Duel.IsMainPhase()
		-- 当前阶段尚未进行过任何操作，即处于主要阶段的开始时
		and not Duel.CheckPhaseActivity()
end
-- 除外用过滤函数：筛选可以里侧除外的卡
function s.cfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 取对象用过滤函数：筛选场上表侧表示且可以回到手卡的卡
function s.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 对象选择处理：先计算可作为代价除外的卡折算后的最大对象数量，确认场上存在可选择的表侧表示卡后，让玩家选择1至该数量的卡为对象，并设置回手卡的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.tgfilter(chkc) end
	-- 计算可选择对象的最大数量：手卡中可里侧除外的卡每张计1张，额外卡组中可里侧除外的卡每6张计1张，合计得到上限
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_HAND,0,e:GetHandler(),tp)+math.floor(Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_EXTRA,0,nil,tp)/6)
	-- 发动可行性检查：可除外的折算数量至少为1，且场上存在至少1张可作为对象的表侧表示卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示「请选择要返回手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家在双方场上选择1至上限数量的表侧表示卡作为效果对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler())
	-- 设置回手卡的操作信息：对象卡组的全部卡确定回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 辅助函数：计算卡组折算后的数量，手卡每张计1，额外卡组每6张计1
function s.getct(g)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)+g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)/6
end
-- 效果处理：取得仍与本效果关联的对象卡，若存在则从手卡和额外卡组选出合计满足条件的卡里侧除外（每1张对象对应1张手卡或6张额外卡组的卡），那之后将对象卡全部回到手卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡，并筛选出仍与本效果关联的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 取得自己手卡和额外卡组中所有可以里侧除外的卡
		local tg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,nil,tp)
		local ct=s.getct(tg)
		if ct>=g:GetCount() then
			-- 向玩家提示「请选择要除外的卡」
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local sg=s.selgroup(tg,tp,g:GetCount())
			-- 若选出的除外卡不为空且成功里侧除外了至少1张，则继续后续处理
			if sg:GetCount()>0 and Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)>0 then
				-- 中断当前效果处理，使之后的回手卡处理与除外处理视为不同时进行
				Duel.BreakEffect()
				-- 将对象卡全部送回持有者的手卡
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			end
		end
	end
end
-- 计分辅助函数：手卡的卡按6分计，额外卡组的卡按1分计
function s.selgroup_count(c)
	if c:IsLocation(LOCATION_HAND) then
		return 6
	else
		return 1
	end
end
-- 让玩家从可除外的卡中选出总分恰好等于对象数量×6的组合（即每1张对象对应1张手卡或6张额外卡组的卡）
function s.selgroup(g,tp,ct)
	return g:SelectWithSumEqual(tp,s.selgroup_count,ct*6,1,#g)
end
