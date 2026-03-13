--ペンデュラム・コール
-- 效果：
-- 「灵摆呼唤」在1回合只能发动1张，把「魔术师」灵摆怪兽的灵摆效果发动过的回合不能发动。
-- ①：丢弃1张手卡才能发动。把2只卡名不同的「魔术师」灵摆怪兽从卡组加入手卡。这张卡的发动后，直到下次的对方回合结束时自己的灵摆区域的「魔术师」卡不会被效果破坏。
function c53208660.initial_effect(c)
	-- 效果原文内容：「灵摆呼唤」在1回合只能发动1张，把「魔术师」灵摆怪兽的灵摆效果发动过的回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,53208660+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c53208660.condition)
	e1:SetCost(c53208660.cost)
	e1:SetTarget(c53208660.target)
	e1:SetOperation(c53208660.activate)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在该回合中发动的连锁次数，以限制「灵摆呼唤」的发动次数。
	Duel.AddCustomActivityCounter(53208660,ACTIVITY_CHAIN,c53208660.chainfilter)
end
-- 过滤函数，判断是否为「魔术师」灵摆魔法卡的发动，如果是则不计入计数器，防止在发动过「魔术师」灵摆效果的回合发动此卡。
function c53208660.chainfilter(re,tp,cid)
	local rc=re:GetHandler()
	-- 获取当前连锁发生的位置信息，用于判断是否为灵摆区域的发动。
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:GetActiveType()==TYPE_PENDULUM+TYPE_SPELL and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and bit.band(loc,LOCATION_PZONE)==LOCATION_PZONE and rc:IsSetCard(0x98))
end
-- 条件函数，检查玩家在本回合中是否已经发动过「灵摆呼唤」的效果。
function c53208660.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回值为0表示该玩家在本回合尚未发动过此卡效果，满足发动条件。
	return Duel.GetCustomActivityCount(53208660,tp,ACTIVITY_CHAIN)==0
end
-- 设置发动代价，要求玩家丢弃1张手牌作为发动的代价。
function c53208660.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手牌的条件，即手牌中至少有1张可丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃手牌的操作，将玩家手牌中的一张卡丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于筛选「魔术师」灵摆怪兽，满足卡名不同且能加入手牌的条件。
function c53208660.thfilter(c)
	return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 目标设置函数，检查是否满足检索2只不同卡名的「魔术师」灵摆怪兽的条件，并设定操作信息。
function c53208660.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取满足条件的「魔术师」灵摆怪兽组，用于后续选择和处理。
		local g=Duel.GetMatchingGroup(c53208660.thfilter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置连锁操作信息，表示将要从卡组检索2张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 激活效果函数，执行检索并加入手牌的操作，并设置灵摆区域的保护效果。
function c53208660.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「魔术师」灵摆怪兽组，用于后续选择和处理。
	local g=Duel.GetMatchingGroup(c53208660.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 then
		-- 提示玩家选择要加入手牌的卡，显示提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从符合条件的卡组中选择2张不同卡名的卡，确保卡名互不相同。
		local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选中的卡加入手牌，并以效果原因处理。
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 向对方确认所选的卡，防止信息泄露。
		Duel.ConfirmCards(1-tp,g1)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 效果原文内容：这张卡的发动后，直到下次的对方回合结束时自己的灵摆区域的「魔术师」卡不会被效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetTargetRange(LOCATION_PZONE,0)
		-- 设置保护效果的目标为玩家自己灵摆区域内的所有「魔术师」卡。
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x98))
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		-- 将该保护效果注册到场上，使其生效至对方回合结束。
		Duel.RegisterEffect(e1,tp)
	end
end
