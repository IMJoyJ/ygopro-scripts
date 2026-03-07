--閃刀亜式－レムニスゲート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地的「闪刀姬」怪兽和「闪刀」魔法卡各相同数量为对象才能发动。那些卡回到卡组。那之后，可以让回去的卡每3张最多1张的场上的卡回到手卡。
-- ②：这张卡在墓地存在的状态，自己场上有「闪刀」怪兽特殊召唤的场合，把这张卡除外才能发动。进行1只「闪刀姬」连接怪兽的连接召唤。
local s,id,o=GetID()
-- 注册卡牌的两个效果：①效果为发动时可以将墓地的「闪刀」魔法卡和「闪刀姬」怪兽送入卡组，之后可以选择最多每3张送入卡组的卡有1张返回手牌；②效果为当自己场上有「闪刀」怪兽特殊召唤时，可以将此卡除外并进行一次「闪刀姬」连接怪兽的连接召唤。
function s.initial_effect(c)
	-- ①：以自己墓地的「闪刀姬」怪兽和「闪刀」魔法卡各相同数量为对象才能发动。那些卡回到卡组。那之后，可以让回去的卡每3张最多1张的场上的卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 为该卡注册一个合并的延迟事件监听器，用于监听自己场上有怪兽特殊召唤成功的事件。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- ②：这张卡在墓地存在的状态，自己场上有「闪刀」怪兽特殊召唤的场合，把这张卡除外才能发动。进行1只「闪刀姬」连接怪兽的连接召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	-- 将此卡除外作为发动②效果的费用。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选墓地中的「闪刀」魔法卡。
function s.sfilter(c,e)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x115) and (not e or c:IsCanBeEffectTarget(e))
end
-- 过滤函数，用于筛选墓地中的「闪刀姬」怪兽。
function s.mfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1115) and (not e or c:IsCanBeEffectTarget(e))
end
-- 判断一个卡组是否满足「闪刀」魔法卡和「闪刀姬」怪兽数量相等的条件。
function s.fselect(g)
	return g:FilterCount(s.sfilter,nil)==g:FilterCount(s.mfilter,nil)
end
-- 实现选择满足条件的「闪刀」魔法卡和「闪刀姬」怪兽的交互逻辑。
function s.SelectSub(g1,g2,tp)
	local max=math.min(#g1,#g2)
	local sg1=Group.CreateGroup()
	local sg2=Group.CreateGroup()
	local sg=sg1+sg2
	local fg=g1+g2
	local finish=false
	while true do
		finish=#sg1==#sg2 and #sg>0
		local sc=fg:SelectUnselect(sg,tp,finish,finish,2,max*2)
		if not sc then break end
		if sg:IsContains(sc) then
			if g1:IsContains(sc) then
				sg1:RemoveCard(sc)
			else
				sg2:RemoveCard(sc)
			end
		else
			if g1:IsContains(sc) then
				sg1:AddCard(sc)
			else
				sg2:AddCard(sc)
			end
		end
		sg=sg1+sg2
		fg=g1+g2-sg
		if #sg1>=max then
			fg=fg-g1
		end
		if #sg2>=max then
			fg=fg-g2
		end
	end
	return sg
end
-- ①效果的发动时点处理函数，用于选择目标卡并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 获取自己墓地中所有「闪刀」魔法卡。
	local g1=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- 获取自己墓地中所有「闪刀姬」怪兽。
	local g2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chkc then return false end
	if chk==0 then return g1:GetCount()>0 and g2:GetCount()>0 end
	local tg=s.SelectSub(g1,g2,tp)
	-- 设置选中的卡为效果的目标。
	Duel.SetTargetCard(tg)
	-- 设置效果操作信息，表示将目标卡送入卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,0,0)
end
-- ①效果的处理函数，将目标卡送入卡组，并根据数量决定是否让场上的卡返回手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的选中卡组。
	local sg=Duel.GetTargetsRelateToChain()
	if #sg==0 then return end
	-- 将选中的卡送入卡组，并判断是否成功。
	if sg:GetCount()>0 and Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 获取实际被操作的卡组。
		local g=Duel.GetOperatedGroup()
		local ct=math.floor(g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)/3)
		-- 获取场上所有可以返回手牌的卡。
		local dg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 判断是否满足返回手牌的条件并询问玩家是否选择。
		if ct>0 and dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否选卡返回手卡？"
			-- 提示玩家选择要返回手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			local dc=dg:Select(tp,1,ct,nil)
			if dc and dc:GetCount()>0 then
				-- 中断当前效果处理，使后续效果视为不同时处理。
				Duel.BreakEffect()
				-- 为选中的卡显示被选为对象的动画效果。
				Duel.HintSelection(dc)
				-- 将选中的卡送入手牌。
				Duel.SendtoHand(dc,nil,REASON_EFFECT)
			end
		end
	end
end
-- 过滤函数，用于筛选自己场上的「闪刀」怪兽。
function s.cfilter(c,tp)
	return c:IsSetCard(0x115) and c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end
-- ②效果的发动条件，判断是否有「闪刀」怪兽被特殊召唤。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤函数，用于筛选可以连接召唤的「闪刀姬」连接怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1115) and c:IsType(TYPE_LINK) and c:IsLinkSummonable(nil)
end
-- ②效果的发动时点处理函数，用于选择目标卡并设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组中是否存在符合条件的「闪刀姬」连接怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置效果操作信息，表示将要特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理函数，选择并进行连接召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择符合条件的「闪刀姬」连接怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		-- 进行连接召唤。
		Duel.LinkSummon(tp,g:GetFirst(),nil)
	end
end
