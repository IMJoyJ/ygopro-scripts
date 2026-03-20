--冷薔薇の抱香
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示怪兽送去墓地才能发动。那只怪兽种族的以下效果适用。
-- ●植物族：这个回合的结束阶段，自己从卡组抽2张，那之后选1张手卡丢弃。
-- ●植物族以外：从卡组把1只4星以下的植物族怪兽加入手卡。
function c53503015.initial_effect(c)
	-- 创建此卡的发动效果，设置为自由连锁，限制每回合只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53503015,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,53503015+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c53503015.cost)
	e1:SetTarget(c53503015.target)
	e1:SetOperation(c53503015.operation)
	c:RegisterEffect(e1)
end
-- 设置发动时的费用处理函数，将标签设为100表示已支付费用
function c53503015.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 过滤函数，用于判断场上是否有满足条件的怪兽（是否为植物族或非植物族）
function c53503015.cfilter(c,chk,p,chk1,chk2)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and ((chk==0 and c:IsRace(RACE_PLANT)==p)
		or ((c:IsRace(RACE_PLANT) and chk1) or (not c:IsRace(RACE_PLANT) and chk2)))
end
-- 检索过滤函数，用于筛选卡组中4星以下且为植物族的怪兽
function c53503015.thfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 设置发动时的目标选择处理，根据场上怪兽种族决定效果类型并选择目标怪兽
function c53503015.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在植物族怪兽可作为发动对象
	local chk1=Duel.IsExistingMatchingCard(c53503015.cfilter,tp,LOCATION_MZONE,0,1,nil,0,true)
	-- 检查场上是否存在非植物族怪兽且卡组中存在符合条件的植物族怪兽
	local chk2=Duel.IsExistingMatchingCard(c53503015.cfilter,tp,LOCATION_MZONE,0,1,nil,0,false)
		-- 确认卡组中存在4星以下的植物族怪兽以供检索
		and Duel.IsExistingMatchingCard(c53503015.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return e:IsHasType(EFFECT_TYPE_ACTIVATE) and chk1 or chk2
	end
	e:SetLabel(0)
	e:SetCategory(0)
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 根据筛选条件选择场上一只怪兽作为发动对象
	local g=Duel.SelectMatchingCard(tp,c53503015.cfilter,tp,LOCATION_MZONE,0,1,1,nil,1,nil,chk1,chk2)
	local opt=g:GetFirst():IsRace(RACE_PLANT) and 0 or 1
	-- 将选中的怪兽送去墓地作为发动费用
	Duel.SendtoGrave(g,REASON_COST)
	if opt==0 then
		e:SetLabel(1)
		e:SetCategory(CATEGORY_DRAW)
		-- 设置效果处理时抽卡的连锁信息，准备从卡组抽2张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
		-- 设置效果处理时丢弃手牌的连锁信息，准备丢弃1张手卡
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	else
		e:SetLabel(2)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置效果处理时检索卡组的连锁信息，准备将1张植物族怪兽加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- 执行发动后的效果处理，根据选择的效果类型注册后续处理
function c53503015.operation(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt==1 then
		-- 创建结束阶段触发的效果，用于在回合结束时抽2张卡并丢弃1张手卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetOperation(c53503015.drop)
		-- 将创建的结束阶段效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	elseif opt==2 then
		-- 提示玩家选择要加入手牌的植物族怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择一只4星以下的植物族怪兽加入手牌
		local g=Duel.SelectMatchingCard(tp,c53503015.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选中的怪兽送入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认所选怪兽的加入手牌
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 定义结束阶段触发的效果处理函数，用于执行抽卡和丢弃操作
function c53503015.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动此卡的动画效果
	Duel.Hint(HINT_CARD,0,53503015)
	-- 执行从卡组抽2张卡的操作
	if Duel.Draw(tp,2,REASON_EFFECT)==2 then
		-- 将玩家的手牌洗切
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 丢弃1张手牌作为抽卡后的处理
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
