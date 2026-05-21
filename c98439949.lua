--無限起動キャンサークレーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只机械族·地属性怪兽解放才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：从自己墓地把1只机械族怪兽除外才能发动。从卡组把1张「超接地展开」加入手卡。
function c98439949.initial_effect(c)
	-- ①：把自己场上1只机械族·地属性怪兽解放才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98439949,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,98439949)
	e1:SetCost(c98439949.spcost)
	e1:SetTarget(c98439949.sptg)
	e1:SetOperation(c98439949.spop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把1只机械族怪兽除外才能发动。从卡组把1张「超接地展开」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98439949,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,98439950)
	e2:SetCost(c98439949.thcost)
	e2:SetTarget(c98439949.thtg)
	e2:SetOperation(c98439949.thop)
	c:RegisterEffect(e2)
end
-- 定义用于特殊召唤Cost的解放怪兽过滤条件：自己场上的地属性·机械族怪兽，且解放后能腾出怪兽区域
function c98439949.cfilter(c,tp)
	-- 检查卡片是否为机械族、地属性，且该卡解放后能让玩家在怪兽区域特殊召唤怪兽
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义特殊召唤效果的Cost：解放自己场上1只地属性·机械族怪兽
function c98439949.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否存在至少1只满足过滤条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c98439949.cfilter,1,nil,tp) end
	-- 选择自己场上1只满足过滤条件的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c98439949.cfilter,1,1,nil,tp)
	-- 将选中的怪兽作为Cost解放
	Duel.Release(g,REASON_COST)
end
-- 定义特殊召唤效果的Target：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c98439949.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁处理的操作信息为：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义特殊召唤效果的Operation：将自身从手卡守备表示特殊召唤
function c98439949.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 定义用于检索Cost的除外怪兽过滤条件：墓地的机械族怪兽，且能作为Cost除外
function c98439949.thcfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 定义检索效果的Cost：从自己墓地把1只机械族怪兽除外
function c98439949.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己墓地是否存在至少1只满足过滤条件的机械族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c98439949.thcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只满足过滤条件的机械族怪兽
	local g=Duel.SelectMatchingCard(tp,c98439949.thcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的墓地怪兽作为Cost表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义检索卡片的过滤条件：卡组中名为「超接地展开」且能加入手牌的卡
function c98439949.thfilter(c)
	return c:IsAbleToHand() and c:IsCode(96462121)
end
-- 定义检索效果的Target：检查卡组中是否存在「超接地展开」，并设置加入手牌的操作信息
function c98439949.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己卡组是否存在至少1张「超接地展开」
	if chk==0 then return Duel.IsExistingMatchingCard(c98439949.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义检索效果的Operation：从卡组把1张「超接地展开」加入手卡
function c98439949.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「超接地展开」
	local g=Duel.SelectMatchingCard(tp,c98439949.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
