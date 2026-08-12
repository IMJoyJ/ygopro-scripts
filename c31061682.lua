--Kozmo－ドロッセル
-- 效果：
-- 「星际仙踪-多萝塞尔」的①的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从手卡把1只4星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
-- ②：这张卡给与对方战斗伤害时，支付500基本分才能发动。从卡组把1张「星际仙踪」卡加入手卡。
function c31061682.initial_effect(c)
	-- ①：把场上的这张卡除外才能发动。从手卡把1只4星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31061682,0))  --"从手卡把「星际仙踪」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,31061682)
	e1:SetCost(c31061682.spcost)
	e1:SetTarget(c31061682.sptg)
	e1:SetOperation(c31061682.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡给与对方战斗伤害时，支付500基本分才能发动。从卡组把1张「星际仙踪」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c31061682.thcon)
	e2:SetCost(c31061682.thcost)
	e2:SetTarget(c31061682.thtg)
	e2:SetOperation(c31061682.thop)
	c:RegisterEffect(e2)
end
-- 将自身从场上除外作为cost
function c31061682.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身从场上除外作为cost
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 筛选手卡中满足条件的「星际仙踪」怪兽
function c31061682.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelAbove(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的条件
function c31061682.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 判断手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c31061682.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤操作
function c31061682.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c31061682.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为对方造成的战斗伤害
function c31061682.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 支付500基本分作为cost
function c31061682.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 筛选卡组中满足条件的「星际仙踪」卡
function c31061682.thfilter(c)
	return c:IsSetCard(0xd2) and c:IsAbleToHand()
end
-- 判断是否满足检索的条件
function c31061682.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c31061682.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作
function c31061682.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c31061682.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
