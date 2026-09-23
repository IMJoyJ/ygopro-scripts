--械刀婪魔皇断
-- 效果：
-- 这张卡的发动和效果不会被无效化。
-- ①：自己的主要阶段1·主要阶段2的开始时，以场上的表侧表示卡任意数量为对象才能发动。作为对象的卡每有1张，自己1张手卡或自己的额外卡组6张卡里侧除外。那之后，作为对象的卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册魔法卡发动效果
function s.initial_effect(c)
	-- ①：自己的主要阶段1·主要阶段2的开始时，以场上的表侧表示卡任意数量为对象才能发动。作为对象的卡每有1张，自己1张手卡或自己的额外卡组6张卡里侧除外。那之后，作为对象的卡回到手卡。
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
	-- 这张卡的发动和效果不会被无效化。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
end
-- 发动的条件：自己的主要阶段开始时（尚未进行操作）
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
		-- 检查当前是否为主阶段
		and Duel.IsMainPhase()
		-- 检查该阶段是否尚未进行任何操作（阶段开始时）
		and not Duel.CheckPhaseActivity()
end
-- 过滤可以里侧表示除外的卡
function s.cfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 过滤场上可以返回手牌的表侧表示卡
function s.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 选择场上任意数量的表侧表示卡作为对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.tgfilter(chkc) end
	-- 计算手卡与额外卡组可支持除外的最大对象数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_HAND,0,e:GetHandler(),tp)+math.floor(Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_EXTRA,0,nil,tp)/6)
	-- 检查是否具备足够的除外资源以及场上是否存在可以作为对象的卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上任意数量的表侧表示卡作为对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler())
	-- 设置操作信息：将选中的对象卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 根据卡片位置计算除外卡支持的对象额度（每1张手牌或每6张额外卡组算1个额度）
function s.getct(g)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)+g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)/6
end
-- 效果处理：除外对应数量的手卡或额外卡组后，将对象卡返回手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取并过滤与效果有联系的对象卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 获取手牌和额外卡组中可以除外的卡
		local tg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,nil,tp)
		local ct=s.getct(tg)
		if ct>=g:GetCount() then
			-- 提示选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local sg=s.selgroup(tg,tp,g:GetCount())
			-- 将选中的卡里侧表示除外
			if sg:GetCount()>0 and Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)>0 then
				-- 中断效果处理（分割前后时点）
				Duel.BreakEffect()
				-- 将对象卡送回手卡
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			end
		end
	end
end
-- 用于组合选择的权重计算函数（手卡计6点权重，额外卡组计1点权重）
function s.selgroup_count(c)
	if c:IsLocation(LOCATION_HAND) then
		return 6
	else
		return 1
	end
end
-- 根据对象数量选择总权重等同于 ct*6 的除外卡片组合
function s.selgroup(g,tp,ct)
	return g:SelectWithSumEqual(tp,s.selgroup_count,ct*6,1,#g)
end
