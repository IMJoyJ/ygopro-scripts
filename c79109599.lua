--沼地の魔神王
-- 效果：
-- ①：融合怪兽融合召唤的场合，手卡·场上·墓地的这张卡可以作为那只融合怪兽有卡名记述的1只融合素材怪兽代用（其他的融合素材不能代用）。
-- ②：把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「融合」加入手卡。
function c79109599.initial_effect(c)
	-- ②：把这张卡从手卡丢弃去墓地才能发动。从卡组把1张「融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79109599,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c79109599.cost)
	e1:SetTarget(c79109599.target)
	e1:SetOperation(c79109599.operation)
	c:RegisterEffect(e1)
	-- ①：融合怪兽融合召唤的场合，手卡·场上·墓地的这张卡可以作为那只融合怪兽有卡名记述的1只融合素材怪兽代用（其他的融合素材不能代用）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e2:SetCondition(c79109599.subcon)
	c:RegisterEffect(e2)
end
-- 限制融合素材代用效果只能在手卡、怪兽区域、墓地适用
function c79109599.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- 发动检索效果的代价：检查并把手卡的这张卡丢弃去墓地
function c79109599.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 作为发动代价将这张卡丢弃去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中卡名为「融合」且能加入手牌的卡
function c79109599.filter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 检索效果的发动准备：检查卡组中是否存在「融合」，并设置将卡片加入手牌的操作信息
function c79109599.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己卡组是否存在至少1张满足过滤条件的「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c79109599.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：让玩家从卡组选择1张「融合」加入手牌并给对方确认
function c79109599.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「融合」
	local g=Duel.SelectMatchingCard(tp,c79109599.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
