--化合獣カーボン・クラブ
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●自己主要阶段才能发动。从卡组把1只二重怪兽送去墓地。那之后，从卡组把1只二重怪兽加入手卡。这个卡名的这个效果1回合只能使用1次。
function c81599449.initial_effect(c)
	-- 为这张卡添加二重怪兽的通用属性（在场上·墓地当作通常怪兽，可再度召唤成为效果怪兽）
	aux.EnableDualAttribute(c)
	-- ●自己主要阶段才能发动。从卡组把1只二重怪兽送去墓地。那之后，从卡组把1只二重怪兽加入手卡。这个卡名的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81599449,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,81599449)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果发动条件为：这张卡处于再度召唤的状态（当作效果怪兽使用）
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c81599449.tgtg)
	e1:SetOperation(c81599449.tgop)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选卡组中可以送去墓地的二重怪兽，且卡组中还存在另一张可以加入手卡的二重怪兽
function c81599449.filter(c,tp)
	return c:IsType(TYPE_DUAL) and c:IsAbleToGrave()
		-- 检查卡组中是否存在至少1张不等于当前筛选卡且可以加入手卡的二重怪兽
		and Duel.IsExistingMatchingCard(c81599449.thfilter,tp,LOCATION_DECK,0,1,c)
end
-- 过滤函数：筛选卡组中可以送去墓地的二重怪兽
function c81599449.tgfilter(c)
	return c:IsType(TYPE_DUAL) and c:IsAbleToGrave()
end
-- 过滤函数：筛选卡组中可以加入手卡的二重怪兽
function c81599449.thfilter(c)
	return c:IsType(TYPE_DUAL) and c:IsAbleToHand()
end
-- 效果发动目标：检查卡组中是否存在满足条件的二重怪兽，并设置送去墓地和加入手卡的操作信息
function c81599449.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查可行性：在发动阶段，检查卡组中是否存在可送去墓地且能后续检索的二重怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c81599449.filter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只二重怪兽送去墓地，成功送墓后，再从卡组选择1只二重怪兽加入手卡
function c81599449.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的二重怪兽
	local g=Duel.SelectMatchingCard(tp,c81599449.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果成功选择卡片，则将其因效果送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0
		and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 获取卡组中所有可以加入手卡的二重怪兽
		local sg=Duel.GetMatchingGroup(c81599449.thfilter,tp,LOCATION_DECK,0,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续的检索手卡处理与送去墓地不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local tg=sg:Select(tp,1,1,nil)
			-- 将选择的卡因效果加入手卡
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 让对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
