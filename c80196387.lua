--天啓の薔薇の鐘
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1只攻击力2400以上的植物族怪兽加入手卡。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只攻击力2400以上的植物族怪兽特殊召唤。
function c80196387.initial_effect(c)
	-- ①：从卡组把1只攻击力2400以上的植物族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80196387,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,80196387)
	e1:SetTarget(c80196387.target)
	e1:SetOperation(c80196387.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只攻击力2400以上的植物族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80196387,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,80196387)
	-- 设置发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c80196387.sptg)
	e2:SetOperation(c80196387.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：攻击力2400以上且可以加入手牌的植物族怪兽
function c80196387.filter(c)
	return c:IsAttackAbove(2400) and c:IsRace(RACE_PLANT) and c:IsAbleToHand()
end
-- 效果①的发动准备与合法性检测函数
function c80196387.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c80196387.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含将卡组的1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数
function c80196387.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c80196387.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：手牌中攻击力2400以上且可以特殊召唤的植物族怪兽
function c80196387.spfilter(c,e,tp)
	return c:IsAttackAbove(2400) and c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检测函数
function c80196387.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手牌中存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c80196387.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从手牌特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的处理函数
function c80196387.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c80196387.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
