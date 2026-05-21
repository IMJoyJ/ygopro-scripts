--銀河の魔導師
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。这张卡的等级直到回合结束时上升4星。
-- ②：把这张卡解放才能发动。从卡组把「银河魔导师」以外的1张「银河」卡加入手卡。
function c98555327.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。这张卡的等级直到回合结束时上升4星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98555327,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(c98555327.lvop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从卡组把「银河魔导师」以外的1张「银河」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98555327,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c98555327.cost)
	e2:SetTarget(c98555327.target)
	e2:SetOperation(c98555327.operation)
	c:RegisterEffect(e2)
end
-- 等级上升效果处理：若自身表侧表示存在且此效果有效，则使其等级上升4星直到回合结束
function c98555327.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的等级直到回合结束时上升4星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(4)
		c:RegisterEffect(e1)
	end
end
-- 发动代价（Cost）检查与处理：检查自身是否可以解放，并在发动时将自身解放
function c98555327.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡组中「银河魔导师」以外的「银河」卡片且能加入手卡
function c98555327.filter(c)
	return c:IsSetCard(0x7b) and not c:IsCode(98555327) and c:IsAbleToHand()
end
-- 发动准备（Target）：检查卡组中是否存在符合条件的卡，并设置检索效果的操作信息
function c98555327.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c98555327.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（Operation）：从卡组选择1张符合条件的卡加入手卡并给对方确认
function c98555327.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c98555327.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
