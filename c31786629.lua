--サンダー・ドラゴン
-- 效果：
-- ①：把这张卡从手卡丢弃才能发动。从卡组把最多2只「雷龙」加入手卡。
function c31786629.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把最多2只「雷龙」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31786629,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c31786629.cost)
	e1:SetTarget(c31786629.target)
	e1:SetOperation(c31786629.operation)
	c:RegisterEffect(e1)
	c31786629.discard_effect=e1
end
-- 发动代价：将这张卡从手卡丢弃；先检查该卡是否可作为代价丢弃，再将其送入墓地。
function c31786629.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 以“代价+丢弃”的原因将这张卡从手卡送入墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索过滤器：卡名必须为「雷龙」（31786629）且能够加入手卡。
function c31786629.filter(c)
	return c:IsCode(31786629) and c:IsAbleToHand()
end
-- 效果发动时的目标判断：确认卡组中存在可检索的「雷龙」，并设置将卡加入手牌的操作信息。
function c31786629.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：卡组中是否存在至少1张符合条件的「雷龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(c31786629.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：标记效果为从卡组将卡加入手牌；此处预计1张，用于连锁判定和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1~2只「雷龙」加入手牌，并向对方展示。
function c31786629.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择卡片的提示文字‘请选择要加入手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1~2张符合条件的「雷龙」（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c31786629.filter,tp,LOCATION_DECK,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示这些加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
