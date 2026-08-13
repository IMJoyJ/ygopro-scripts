--ペンデュラム・コール
-- 效果：
-- 「灵摆呼唤」在1回合只能发动1张，把「魔术师」灵摆怪兽的灵摆效果发动过的回合不能发动。
-- ①：丢弃1张手卡才能发动。把2只卡名不同的「魔术师」灵摆怪兽从卡组加入手卡。这张卡的发动后，直到下次的对方回合结束时自己的灵摆区域的「魔术师」卡不会被效果破坏。
function c53208660.initial_effect(c)
	-- 「灵摆呼唤」在1回合只能发动1张，把「魔术师」灵摆怪兽的灵摆效果发动过的回合不能发动。①：丢弃1张手卡才能发动。把2只卡名不同的「魔术师」灵摆怪兽从卡组加入手卡。这张卡的发动后，直到下次的对方回合结束时自己的灵摆区域的「魔术师」卡不会被效果破坏。
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
	-- 注册一个自定义活动计数器（ACTIVITY_CHAIN），统计本回合是否发动过满足chainfilter条件的「魔术师」灵摆怪兽的灵摆效果，用于实现“把「魔术师」灵摆怪兽的灵摆效果发动过的回合不能发动”的限制。
	Duel.AddCustomActivityCounter(53208660,ACTIVITY_CHAIN,c53208660.chainfilter)
end
-- chainfilter过滤函数：判断当前发动的连锁是否为「魔术师」灵摆怪兽在灵摆区域发动的灵摆效果（非魔陷的发动），若是则返回false使计数器累计，从而禁止本回合发动此卡。
function c53208660.chainfilter(re,tp,cid)
	local rc=re:GetHandler()
	-- 获取当前连锁发动时的位置，用于判断效果是否在灵摆区域发动。
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:GetActiveType()==TYPE_PENDULUM+TYPE_SPELL and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and bit.band(loc,LOCATION_PZONE)==LOCATION_PZONE and rc:IsSetCard(0x98))
end
-- 发动条件函数：检查自己本回合是否没有发动过「魔术师」灵摆效果（计数器为0），满足条件才可发动本卡。
function c53208660.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自定义计数器的值为0，即本回合自己尚未发动过「魔术师」灵摆效果。
	return Duel.GetCustomActivityCount(53208660,tp,ACTIVITY_CHAIN)==0
end
-- 发动代价函数：丢弃1张手卡作为发动「灵摆呼唤」的COST。
function c53208660.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在COST检测阶段，检查手牌中是否存在至少1张可以丢弃的卡（排除发动卡自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：从手牌丢弃1张卡，丢弃原因标记为COST并丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索过滤器：筛选卡组中卡名含有「魔术师」、为灵摆怪兽且可以加入手卡的卡。
function c53208660.thfilter(c)
	return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 发动目标函数：确认卡组中有至少2种不同卡名的「魔术师」灵摆怪兽，并设置将2张加入手卡的操作信息。
function c53208660.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有满足检索条件的「魔术师」灵摆怪兽。
		local g=Duel.GetMatchingGroup(c53208660.thfilter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置本次效果的操作信息：从卡组把2张卡加入手卡（不取对象，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果处理函数：从满足条件的卡组中选出2张卡名不同的「魔术师」灵摆怪兽加入手卡，并赋予后续的灵摆区破坏保护效果。
function c53208660.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时再次获取卡组中满足检索条件的「魔术师」灵摆怪兽。
	local g=Duel.GetMatchingGroup(c53208660.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 then
		-- 向操作玩家显示“请选择要加入手牌的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 由玩家从检索到的卡组中选择2张卡名互不相同的「魔术师」灵摆怪兽。
		local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选择的2张卡送入持有者的手卡，处理原因为效果。
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 向对方玩家确认展示加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g1)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下次的对方回合结束时自己的灵摆区域的「魔术师」卡不会被效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetTargetRange(LOCATION_PZONE,0)
		-- 设置保护效果的作用对象为卡名含有「魔术师」的卡（在自己的灵摆区域）。
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x98))
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		-- 将“不会被效果破坏”的保护效果注册到当前玩家，持续到下次对方回合结束。
		Duel.RegisterEffect(e1,tp)
	end
end
