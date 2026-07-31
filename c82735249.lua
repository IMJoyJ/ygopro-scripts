--ゲネラールプローベ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，每次「音响战士」卡持有的效果发动，给这张卡放置1个音响指示物。
-- ②：把自己场上3个音响指示物取除才能发动。从卡组把1只「音响战士」怪兽加入手卡。
-- ③：自己对「音响战士」怪兽的召唤·特殊召唤成功的场合才能发动。从卡组把1张「音响放大器」加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册永续魔法发动、音响指示物放置、去除3个指示物检索「音响战士」怪兽、以及「音响战士」召唤/特召成功检索「音响放大器」的效果
function c82735249.initial_effect(c)
	-- 记录此卡记载了「音响放大器」(75304793)的卡名
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
	-- ②：把自己场上3个音响指示物去除才能发动。从卡组把1只「音响战士」怪兽加入手卡。
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
c82735249.mentioned_counter={
	[0x35]=true,
}
-- 指示物放置条件：连锁处理中的效果为「音响战士」卡发动的效果，且非卡片发动
function c82735249.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x1066) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 指示物放置处理：给此卡放置1个音响指示物
function c82735249.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x35,1)
end
-- ②效果发动Cost：去除自己场上3个音响指示物
function c82735249.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：自己场上是否存在至少3个可去除的音响指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x35,3,REASON_COST) end
	-- 从自己场上去除3个音响指示物
	Duel.RemoveCounter(tp,1,0,0x35,3,REASON_COST)
end
-- 卡组检索过滤条件：「音响战士」怪兽且可加入手牌
function c82735249.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1066) and c:IsAbleToHand()
end
-- ②效果发动准备：设置从卡组检索「音响战士」怪兽的操作信息
function c82735249.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中是否存在可加入手牌的「音响战士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c82735249.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组把1只「音响战士」怪兽加入手牌
function c82735249.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的「音响战士」怪兽
	local g=Duel.SelectMatchingCard(tp,c82735249.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「音响战士」怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己召唤/特殊召唤成功的表侧表示「音响战士」怪兽
function c82735249.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1066) and c:IsSummonPlayer(tp)
end
-- ③效果发动条件：自己成功召唤/特殊召唤了「音响战士」怪兽
function c82735249.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c82735249.cfilter,1,nil,tp)
end
-- 卡组检索过滤条件：「音响放大器」(75304793)且可加入手牌
function c82735249.thfilter2(c)
	return c:IsCode(75304793) and c:IsAbleToHand()
end
-- ③效果发动准备：设置从卡组检索「音响放大器」的操作信息
function c82735249.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中是否存在可加入手牌的「音响放大器」
	if chk==0 then return Duel.IsExistingMatchingCard(c82735249.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组把1张「音响放大器」加入手牌
function c82735249.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「音响放大器」
	local g=Duel.SelectMatchingCard(tp,c82735249.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「音响放大器」加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
