--ホルスの栄光－イムセティ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：自己场上有「王之棺」存在的场合，这张卡可以从墓地特殊召唤。
-- ②：从手卡把包含这张卡的2张卡送去墓地才能发动。从卡组把1张「王之棺」加入手卡。那之后，自己可以抽1张。
-- ③：这张卡在怪兽区域存在的状态，自己场上的其他卡因对方的效果从场上离开的场合才能发动。场上1张卡送去墓地。
function c84941194.initial_effect(c)
	-- 注册卡片关联密码，表示这张卡的效果文本中记载了「王之棺」（卡号16528181）
	aux.AddCodeList(c,16528181)
	-- ①：自己场上有「王之棺」存在的场合，这张卡可以从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,84941194+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c84941194.sprcon)
	c:RegisterEffect(e1)
	-- ②：从手卡把包含这张卡的2张卡送去墓地才能发动。从卡组把1张「王之棺」加入手卡。那之后，自己可以抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84941194,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,84941195)
	e2:SetCost(c84941194.tgcost)
	e2:SetTarget(c84941194.target)
	e2:SetOperation(c84941194.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡在怪兽区域存在的状态，自己场上的其他卡因对方的效果从场上离开的场合才能发动。场上1张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84941194,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,84941196)
	e3:SetCondition(c84941194.descon)
	e3:SetTarget(c84941194.destg)
	e3:SetOperation(c84941194.desop)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示且卡名为「王之棺」的卡
function c84941194.sprfilter(c)
	return c:IsFaceup() and c:IsCode(16528181)
end
-- 特殊召唤规则的条件：检查墓地不受王家之谷影响、怪兽区域有空位，且自己场上存在「王之棺」
function c84941194.sprcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的「王之棺」
		and Duel.IsExistingMatchingCard(c84941194.sprfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：可以作为发动成本送去墓地的卡
function c84941194.costfilter(c)
	return c:IsAbleToGraveAsCost()
end
-- 效果②的发动成本处理：从手卡将包含这张卡在内的2张卡送去墓地
function c84941194.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡中除这张卡以外是否还有至少1张可以送去墓地的卡，且这张卡自身也能作为成本送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c84941194.costfilter,tp,LOCATION_HAND,0,1,c) and c:IsAbleToGraveAsCost() end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1张除这张卡以外的卡
	local g=Duel.SelectMatchingCard(tp,c84941194.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选中的卡和这张卡作为发动成本送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：卡名为「王之棺」且能加入手卡的卡
function c84941194.filter(c)
	return c:IsCode(16528181) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组中是否存在「王之棺」，并设置检索的操作信息
function c84941194.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「王之棺」
	if chk==0 then return Duel.IsExistingMatchingCard(c84941194.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为“从卡组将1张卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组将「王之棺」加入手卡，之后可选择抽1张卡
function c84941194.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第一张满足条件的「王之棺」
	local tg=Duel.GetFirstMatchingCard(c84941194.filter,tp,LOCATION_DECK,0,nil)
	-- 将「王之棺」加入手卡并给对方确认，确认成功后继续处理
	if tg and Duel.SendtoHand(tg,nil,REASON_EFFECT)~=0 and Duel.ConfirmCards(1-tp,tg)~=0
		-- 检查玩家是否可以抽卡，并询问玩家是否选择抽卡
		and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(84941194,2)) then  --"是否抽卡？"
			-- 洗切玩家的卡组
			Duel.ShuffleDeck(tp)
			-- 中断当前效果处理，使后续的抽卡处理与检索处理不视为同时进行（错时点）
			Duel.BreakEffect()
			-- 玩家从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 过滤条件：原本由自己控制、因对方的效果而离开场上的卡
function c84941194.cfilter(c,tp)
	return c:IsPreviousControler(tp)
		and c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)
end
-- 效果③的发动条件：自己场上除这张卡以外的其他卡因对方的效果从场上离开
function c84941194.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c84941194.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果③的发动准备：检查场上是否存在可以送去墓地的卡，并设置送去墓地的操作信息
function c84941194.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上（双方场上）是否存在可以送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 设置效果处理信息为“将场上的1张卡送去墓地”
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
end
-- 效果③的效果处理：选择场上1张卡送去墓地
function c84941194.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择场上（双方场上）的1张卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 选中卡片并向双方玩家展示（显示选中动画）
		Duel.HintSelection(g)
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
