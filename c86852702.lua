--機甲部隊の再編制
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●丢弃1张手卡才能发动。从卡组把2只「机甲」怪兽加入手卡（同名卡最多1张）。
-- ●从手卡丢弃1张「机甲」卡才能发动。从卡组把「机甲部队的再编制」以外的2张「机甲」卡加入手卡（同名卡最多1张）。
function c86852702.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●丢弃1张手卡才能发动。从卡组把2只「机甲」怪兽加入手卡（同名卡最多1张）。●从手卡丢弃1张「机甲」卡才能发动。从卡组把「机甲部队的再编制」以外的2张「机甲」卡加入手卡（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86852702,0))  --"检索「机甲」怪兽"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,86852702+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c86852702.cost)
	e1:SetTarget(c86852702.target)
	e1:SetOperation(c86852702.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价函数，利用Label标记来区分是否在发动阶段进行代价检测
function c86852702.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 过滤手牌中可丢弃的「机甲」卡
function c86852702.costfilter(c)
	return c:IsSetCard(0x36) and c:IsDiscardable()
end
-- 过滤卡组中可加入手牌的「机甲」怪兽
function c86852702.thfilter1(c)
	return c:IsSetCard(0x36) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤卡组中可加入手牌的「机甲部队的再编制」以外的「机甲」卡
function c86852702.thfilter2(c)
	return c:IsSetCard(0x36) and not c:IsCode(86852702) and c:IsAbleToHand()
end
-- 定义发动时的目标选择与代价支付处理函数，包含分支选择和丢弃手牌代价的执行
function c86852702.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取卡组中不同卡名的「机甲」怪兽的种类数量
	local count1=Duel.GetMatchingGroup(c86852702.thfilter1,tp,LOCATION_DECK,0,nil):GetClassCount(Card.GetCode)
	-- 获取卡组中不同卡名的「机甲部队的再编制」以外的「机甲」卡的种类数量
	local count2=Duel.GetMatchingGroup(c86852702.thfilter2,tp,LOCATION_DECK,0,nil):GetClassCount(Card.GetCode)
	-- 检查是否满足分支1的发动条件：手牌有可丢弃的卡，且卡组有至少2种「机甲」怪兽
	local b1=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) and count1>=2
	-- 检查是否满足分支2的发动条件：手牌有可丢弃的「机甲」卡，且卡组有至少2种「机甲部队的再编制」以外的「机甲」卡
	local b2=Duel.IsExistingMatchingCard(c86852702.costfilter,tp,LOCATION_HAND,0,1,c) and count2>=2
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			return b1 or b2
		else
			return count1>=2 or count2>=2
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		local op=0
		if b1 and b2 then
			-- 在需要支付代价且两个分支均满足时，让玩家选择发动其中一个效果
			op=Duel.SelectOption(tp,aux.Stringid(86852702,0),aux.Stringid(86852702,1))  --"检索「机甲」怪兽/检索「机甲」卡"
		elseif b1 then
			-- 在需要支付代价且仅满足分支1时，强制选择分支1
			op=Duel.SelectOption(tp,aux.Stringid(86852702,0))  --"检索「机甲」怪兽"
		else
			-- 在需要支付代价且仅满足分支2时，强制选择分支2
			op=Duel.SelectOption(tp,aux.Stringid(86852702,1))+1  --"检索「机甲」卡"
		end
		if op==0 then
			-- 执行分支1的代价：从手牌丢弃1张卡
			Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
		else
			-- 执行分支2的代价：从手牌丢弃1张「机甲」卡
			Duel.DiscardHand(tp,c86852702.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
		end
		e:SetLabel(0,op)
	else
		local op=0
		if count1>=2 and count2>=2 then
			-- 在不需支付代价且两个分支均满足时，让玩家选择发动其中一个效果
			op=Duel.SelectOption(tp,aux.Stringid(86852702,0),aux.Stringid(86852702,1))  --"检索「机甲」怪兽/检索「机甲」卡"
		elseif count1>=2 then
			-- 在不需支付代价且仅满足分支1时，强制选择分支1
			op=Duel.SelectOption(tp,aux.Stringid(86852702,0))  --"检索「机甲」怪兽"
		else
			-- 在不需支付代价且仅满足分支2时，强制选择分支2
			op=Duel.SelectOption(tp,aux.Stringid(86852702,1))+1  --"检索「机甲」卡"
		end
		e:SetLabel(0,op)
	end
	-- 设置效果处理时的操作信息：从卡组将2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 定义效果处理的执行函数，根据玩家选择的分支进行检索处理
function c86852702.activate(e,tp,eg,ep,ev,re,r,rp)
	local label,op=e:GetLabel()
	if op==0 then
		-- 获取卡组中所有满足条件的「机甲」怪兽
		local g=Duel.GetMatchingGroup(c86852702.thfilter1,tp,LOCATION_DECK,0,nil)
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从过滤出的怪兽中选择2张卡名不同的卡
		local hg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		if hg then
			-- 将选中的2张「机甲」怪兽加入手牌
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡片
			Duel.ConfirmCards(1-tp,hg)
		end
	else
		-- 获取卡组中所有满足条件的「机甲部队的再编制」以外的「机甲」卡
		local g=Duel.GetMatchingGroup(c86852702.thfilter2,tp,LOCATION_DECK,0,nil)
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从过滤出的卡片中选择2张卡名不同的卡
		local hg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		if hg then
			-- 将选中的2张「机甲」卡加入手牌
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡片
			Duel.ConfirmCards(1-tp,hg)
		end
	end
end
