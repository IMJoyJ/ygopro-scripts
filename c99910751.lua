--はぐれ・もけもけ
-- 效果：
-- ①：这张卡只要在场上·墓地存在，卡名变成「悠悠」，当作通常怪兽使用。
-- ②：把这张卡从手卡丢弃才能发动。从卡组把「落单悠悠」以外的1张「悠悠」卡加入手卡。
function c99910751.initial_effect(c)
	-- 注册效果：这张卡在场上·墓地存在时卡名变成「悠悠」（卡号27288416）。
	aux.EnableChangeCode(c,27288416,LOCATION_MZONE+LOCATION_GRAVE)
	-- 当作通常怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_REMOVE_TYPE)
	e2:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：把这张卡从手卡丢弃才能发动。从卡组把「落单悠悠」以外的1张「悠悠」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCost(c99910751.thcost)
	e3:SetTarget(c99910751.thtg)
	e3:SetOperation(c99910751.thop)
	c:RegisterEffect(e3)
end
-- 效果②的发动代价：从手卡丢弃这张卡（将这张卡送入墓地作为代价）。
function c99910751.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 把这张卡送去墓地，作为发动代价（丢弃）。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索的过滤条件：不是「落单悠悠」自身、属于「悠悠」系列（0x183）、且能够加入手牌的卡。
function c99910751.thfilter(c)
	return not c:IsCode(99910751) and c:IsSetCard(0x183) and c:IsAbleToHand()
end
-- 效果②的发动时处理：确认卡组存在符合条件的「悠悠」卡，并设置将卡加入手牌的操作信息。
function c99910751.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：卡组中存在至少1张符合条件的「悠悠」卡（不取对象，效果处理时检索）。
	if chk==0 then return Duel.IsExistingMatchingCard(c99910751.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息为“从卡组将1张卡加入手牌”，用于触发相关卡片的连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组选1张符合条件的「悠悠」卡加入手牌，并展示给对方确认。
function c99910751.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示文案为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足thfilter过滤条件的「悠悠」卡。
	local g=Duel.SelectMatchingCard(tp,c99910751.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手牌的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
