--御影志士
-- 效果：
-- 4星怪兽×2
-- 这个卡名的效果1回合只能使用1次。
-- ①：可以把这张卡1个超量素材取除，从以下效果选择1个发动。
-- ●从卡组把1只岩石族怪兽加入手卡。
-- ●从手卡把1只岩石族怪兽里侧守备表示特殊召唤。
function c32530043.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用2只4星怪兽叠放进行超量召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：可以把这张卡1个超量素材取除，从以下效果选择1个发动。●从卡组把1只岩石族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32530043,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,32530043)
	e1:SetCost(c32530043.cost)
	e1:SetTarget(c32530043.thtg)
	e1:SetOperation(c32530043.thop)
	c:RegisterEffect(e1)
	-- ●从手卡把1只岩石族怪兽里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32530043,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,32530043)
	e2:SetCost(c32530043.cost)
	e2:SetTarget(c32530043.sptg)
	e2:SetOperation(c32530043.spop)
	c:RegisterEffect(e2)
end
-- 代价处理：发动时检查能否去除1个超量素材，若可则实际去除1个超量素材，并向对方提示所选择发动的是哪个效果。
function c32530043.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 向对方玩家发送提示，告知对方自己选择发动了哪个效果（显示当前效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义检索用的过滤函数：判断卡是否为岩石族怪兽且可以被加入手卡。
function c32530043.thfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToHand()
end
-- 第一个效果的发动目标判定：若卡组存在至少1只符合条件的岩石族怪兽则可发动，并设置将1张卡从卡组加入手卡的操作信息。
function c32530043.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足thfilter条件的岩石族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c32530043.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本连锁的操作信息：将从卡组把1张卡加入手卡（具体卡不确定，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 第一个效果的处理：从卡组选择1只岩石族怪兽加入手卡，并向对方展示该卡。
function c32530043.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示从卡组选择要加入手牌的卡的提示文字：“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选择1张符合条件的岩石族怪兽（此时必定能选到）。
	local g=Duel.SelectMatchingCard(tp,c32530043.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义特殊召唤用的过滤函数：判断手牌中的怪兽是否为岩石族，且可以里侧守备表示特殊召唤。
function c32530043.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 第二个效果的发动目标判定：己方主要怪兽区有空位，且手牌存在至少1只符合条件的岩石族怪兽，则可发动。
function c32530043.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足spfilter条件的岩石族怪兽。
		and Duel.IsExistingMatchingCard(c32530043.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本连锁的操作信息：将从手牌特殊召唤1只怪兽（具体卡在效果处理时选择，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 第二个效果的处理：从手牌选择1只岩石族怪兽以里侧守备表示特殊召唤，并向对方展示该卡。
function c32530043.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方主要怪兽区没有空位，则效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示从手牌选择要特殊召唤的卡的提示文字：“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1张符合条件的岩石族怪兽。
	local g=Duel.SelectMatchingCard(tp,c32530043.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以里侧守备表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方确认特殊召唤的怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
end
