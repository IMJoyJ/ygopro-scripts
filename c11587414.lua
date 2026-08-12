--真なる太陽神
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，除「真正的太阳神」外的1只「太阳神之翼神龙」或者1张有那个卡名记述的卡从卡组加入手卡。
-- ②：「太阳神之翼神龙」以外的特殊召唤的怪兽在那个回合不能攻击。
-- ③：1回合1次，自己主要阶段才能发动。这张卡或者卡组1只「太阳神之翼神龙-不死鸟」送去墓地。那之后，选自己场上1只「太阳神之翼神龙」送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果，注册3个效果：①检索效果、②禁止攻击效果、③主要阶段发动的墓地处理效果
function s.initial_effect(c)
	-- 记录该卡具有「太阳神之翼神龙」的卡名记述
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
-- 定义检索过滤函数，用于筛选卡组中「太阳神之翼神龙」或其记述卡且不是本卡的卡
function s.filter(c)
	-- 筛选卡组中「太阳神之翼神龙」或其记述卡且不是本卡的卡
	return aux.IsCodeOrListed(c,10000010) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 定义①效果的发动条件，检查卡组中是否存在满足条件的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置①效果的处理信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义①效果的处理函数，提示玩家选择卡并将其加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义禁止攻击效果的目标过滤函数，判断是否为本回合特殊召唤且不是「太阳神之翼神龙」的怪兽
function s.attg(e,c)
	return c:IsStatus(STATUS_SPSUMMON_TURN) and not c:IsCode(10000010)
end
-- 定义③效果中用于检索卡组的过滤函数，筛选「太阳神之翼神龙-不死鸟」
function s.tgfilter1(c)
	return c:IsAbleToGrave() and c:IsCode(10000090)
end
-- 定义③效果中用于选择场上怪兽的过滤函数，筛选场上表侧表示的「太阳神之翼神龙」
function s.tgfilter2(c)
	return c:IsAbleToGrave() and c:IsCode(10000010) and c:IsFaceup()
end
-- 定义③效果的发动条件，检查是否满足发动条件
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (e:GetHandler():IsAbleToGrave()
			-- 检查卡组中是否存在「太阳神之翼神龙-不死鸟」
			or Duel.IsExistingMatchingCard(s.tgfilter1,tp,LOCATION_DECK,0,1,nil))
		-- 检查场上是否存在表侧表示的「太阳神之翼神龙」
		and Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置③效果的处理信息，表示将从场上和卡组送去墓地2张卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_MZONE+LOCATION_DECK)
end
-- 定义③效果的处理函数，选择并处理卡牌的送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取卡组中所有「太阳神之翼神龙-不死鸟」
	local g=Duel.GetMatchingGroup(s.tgfilter1,tp,LOCATION_DECK,0,nil)
	if c:IsRelateToChain() and c:IsAbleToGrave() then g:AddCard(c) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg1=g:Select(tp,1,1,nil)
	-- 将选中的卡送去墓地并确认是否成功
	if Duel.SendtoGrave(sg1,REASON_EFFECT)>0 and sg1:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从场上选择满足条件的「太阳神之翼神龙」
		local sg2=Duel.SelectMatchingCard(tp,s.tgfilter2,tp,LOCATION_MZONE,0,1,1,nil)
		if #sg2>0 then
			-- 中断当前效果，使后续效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的「太阳神之翼神龙」送去墓地
			Duel.SendtoGrave(sg2,REASON_EFFECT)
		end
	end
end
