--真なる太陽神
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，除「真正的太阳神」外的1只「太阳神之翼神龙」或者1张有那个卡名记述的卡从卡组加入手卡。
-- ②：「太阳神之翼神龙」以外的特殊召唤的怪兽在那个回合不能攻击。
-- ③：1回合1次，自己主要阶段才能发动。这张卡或者卡组1只「太阳神之翼神龙-不死鸟」送去墓地。那之后，选自己场上1只「太阳神之翼神龙」送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- 为卡片注册“有太阳神之翼神龙记述”的卡片代码列表
	aux.AddCodeList(c,10000010)
	-- ①：作为这张卡的发动时的效果处理，除「真正的太阳神」外的1只「太阳神之翼神龙」或者1张有那个卡名记述的卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：「太阳神之翼神龙」以外的特殊召唤的怪兽在那个回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.attg)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己主要阶段才能发动。这张卡或者卡组1只「太阳神之翼神龙-不死鸟」送去墓地。那之后，选自己场上1只「太阳神之翼神龙」送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 定义用于筛选目标卡的过滤函数
function s.filter(c)
	-- 筛选满足条件的卡：为太阳神之翼神龙或其记述卡，且不是本卡，且能加入手牌
	return aux.IsCodeOrListed(c,10000010) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 定义发动时的处理函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：卡组中存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置发动时的操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义发动效果的处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义攻击限制的过滤函数
function s.attg(e,c)
	return c:IsStatus(STATUS_SPSUMMON_TURN) and not c:IsCode(10000010)
end
-- 定义用于筛选卡组中不死鸟的过滤函数
function s.tgfilter1(c)
	return c:IsAbleToGrave() and c:IsCode(10000090)
end
-- 定义用于筛选场上太阳神之翼神龙的过滤函数
function s.tgfilter2(c)
	return c:IsAbleToGrave() and c:IsCode(10000010) and c:IsFaceup()
end
-- 定义效果3的发动处理函数
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (e:GetHandler():IsAbleToGrave()
			-- 判断是否满足发动条件：场上有不死鸟或卡组中有不死鸟
			or Duel.IsExistingMatchingCard(s.tgfilter1,tp,LOCATION_DECK,0,1,nil))
		-- 判断是否满足发动条件：场上存在太阳神之翼神龙
		and Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置发动时的操作信息：将2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_MZONE+LOCATION_DECK)
end
-- 定义效果3的处理函数
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取卡组中满足条件的不死鸟
	local g=Duel.GetMatchingGroup(s.tgfilter1,tp,LOCATION_DECK,0,nil)
	if c:IsRelateToChain() and c:IsAbleToGrave() then g:AddCard(c) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg1=g:Select(tp,1,1,nil)
	-- 将选中的卡送去墓地并判断是否成功
	if Duel.SendtoGrave(sg1,REASON_EFFECT)>0 and sg1:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 提示玩家选择要送去墓地的太阳神之翼神龙
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		-- 从场上选择满足条件的太阳神之翼神龙
		local sg2=Duel.SelectMatchingCard(tp,s.tgfilter2,tp,LOCATION_MZONE,0,1,1,nil)
		if #sg2>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将选中的太阳神之翼神龙送去墓地
			Duel.SendtoGrave(sg2,REASON_EFFECT)
		end
	end
end
