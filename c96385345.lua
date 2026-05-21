--薔薇の聖騎士
-- 效果：
-- 「蔷薇之圣骑士」的②的效果1回合只能使用1次。
-- ①：这张卡战斗破坏对方怪兽送去墓地时，把这张卡解放才能发动。从手卡·卡组把1只植物族怪兽守备表示特殊召唤。
-- ②：把这张卡从手卡送去墓地才能发动。从卡组把1只7星以上的植物族怪兽加入手卡。
function c96385345.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时，把这张卡解放才能发动。从手卡·卡组把1只植物族怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c96385345.spcon)
	e1:SetCost(c96385345.spcost)
	e1:SetTarget(c96385345.sptg)
	e1:SetOperation(c96385345.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡从手卡送去墓地才能发动。从卡组把1只7星以上的植物族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,96385345)
	e2:SetCost(c96385345.thcost)
	e2:SetTarget(c96385345.thtg)
	e2:SetOperation(c96385345.thop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否战斗破坏对方怪兽并送去墓地
function c96385345.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsType(TYPE_MONSTER) and bc:IsLocation(LOCATION_GRAVE)
end
-- 解放此卡作为发动的代价
function c96385345.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤手卡·卡组中可以守备表示特殊召唤的植物族怪兽
function c96385345.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的发动准备与合法性检测
function c96385345.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用空位（因自身解放，可用空位需大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡·卡组是否存在可特殊召唤的植物族怪兽
		and Duel.IsExistingMatchingCard(c96385345.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从手卡·卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的处理
function c96385345.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若怪兽区域没有空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只满足条件的植物族怪兽
	local g=Duel.SelectMatchingCard(tp,c96385345.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 将手卡的此卡送去墓地作为发动的代价
function c96385345.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中7星以上的植物族怪兽
function c96385345.thfilter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_PLANT) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检测
function c96385345.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在7星以上的植物族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96385345.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手卡的操作信息，预计从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理
function c96385345.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只7星以上的植物族怪兽
	local g=Duel.SelectMatchingCard(tp,c96385345.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
