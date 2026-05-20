--ゲネラールプローベ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，每次「音响战士」卡持有的效果发动，给这张卡放置1个音响指示物。
-- ②：把自己场上3个音响指示物取除才能发动。从卡组把1只「音响战士」怪兽加入手卡。
-- ③：自己对「音响战士」怪兽的召唤·特殊召唤成功的场合才能发动。从卡组把1张「音响放大器」加入手卡。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果：关联「音响放大器」、允许放置指示物、卡片发动、每次「音响战士」卡效果发动放置指示物、去除3个指示物检索「音响战士」怪兽、召唤·特殊召唤成功时检索「音响放大器」
function c82735249.initial_effect(c)
	-- 将「音响放大器」记录在此卡的关联卡片列表中
	aux.AddCodeList(c,75304793)
	c:EnableCounterPermit(0x35)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，每次「音响战士」卡持有的效果发动，给这张卡放置1个音响指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c82735249.ctcon)
	e2:SetOperation(c82735249.ctop)
	c:RegisterEffect(e2)
	-- ②：把自己场上3个音响指示物取除才能发动。从卡组把1只「音响战士」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,82735249)
	e3:SetCost(c82735249.thcost)
	e3:SetTarget(c82735249.thtg)
	e3:SetOperation(c82735249.thop)
	c:RegisterEffect(e3)
	-- ③：自己对「音响战士」怪兽的召唤·特殊召唤成功的场合才能发动。从卡组把1张「音响放大器」加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,82735249+o)
	e4:SetCondition(c82735249.thcon2)
	e4:SetTarget(c82735249.thtg2)
	e4:SetOperation(c82735249.thop2)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 检查发动的效果是否为「音响战士」卡片持有的效果，且不是魔法·陷阱卡的发动
function c82735249.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x1066) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 给这张卡放置1个音响指示物
function c82735249.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x35,1)
end
-- 效果②的发动代价：检查并从己方场上移去3个音响指示物
function c82735249.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能以发动代价为原因移去己方场上的3个音响指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x35,3,REASON_COST) end
	-- 移去己方场上的3个音响指示物作为发动代价
	Duel.RemoveCounter(tp,1,0,0x35,3,REASON_COST)
end
-- 过滤条件：卡组中的「音响战士」怪兽，且能加入手卡
function c82735249.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1066) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组中是否存在符合条件的「音响战士」怪兽，并设置检索的操作信息
function c82735249.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组中是否存在至少1只可以加入手卡的「音响战士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c82735249.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示此效果会从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组选择1只「音响战士」怪兽加入手卡，并给对方确认
function c82735249.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从己方卡组选择1张符合条件的「音响战士」怪兽
	local g=Duel.SelectMatchingCard(tp,c82735249.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：由己方召唤·特殊召唤成功的表侧表示「音响战士」怪兽
function c82735249.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1066) and c:IsSummonPlayer(tp)
end
-- 效果③的发动条件：检查当前召唤·特殊召唤成功的怪兽中是否存在己方的「音响战士」怪兽
function c82735249.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c82735249.cfilter,1,nil,tp)
end
-- 过滤条件：卡组中的「音响放大器」，且能加入手卡
function c82735249.thfilter2(c)
	return c:IsCode(75304793) and c:IsAbleToHand()
end
-- 效果③的发动准备：检查卡组中是否存在「音响放大器」，并设置检索的操作信息
function c82735249.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组中是否存在至少1张可以加入手卡的「音响放大器」
	if chk==0 then return Duel.IsExistingMatchingCard(c82735249.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示此效果会从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理：从卡组选择1张「音响放大器」加入手卡，并给对方确认
function c82735249.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从己方卡组选择1张「音响放大器」
	local g=Duel.SelectMatchingCard(tp,c82735249.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
