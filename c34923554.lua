--無限起動ドラグショベル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只机械族·地属性怪兽解放才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：从自己墓地把1只机械族怪兽除外才能发动。从卡组把1张「超信地旋回」加入手卡。
function c34923554.initial_effect(c)
	-- ①：把自己场上1只机械族·地属性怪兽解放才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34923554,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,34923554)
	e1:SetCost(c34923554.spcost)
	e1:SetTarget(c34923554.sptg)
	e1:SetOperation(c34923554.spop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把1只机械族怪兽除外才能发动。从卡组把1张「超信地旋回」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34923554,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,34923555)
	e2:SetCost(c34923554.thcost)
	e2:SetTarget(c34923554.thtg)
	e2:SetOperation(c34923554.thop)
	c:RegisterEffect(e2)
end
-- 定义筛选函数cfilter，用于检查作为①效果解放素材的怪兽是否满足机械族·地属性且解放后有空位。
function c34923554.cfilter(c,tp)
	-- 检查候选怪兽是否为机械族·地属性，并判断解放该怪兽后自己场上是否仍有可用的怪兽区空格。
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and Duel.GetMZoneCount(tp,c)>0
end
-- spcost为①效果的发动代价函数：确认存在可解放素材后，选择1只机械族·地属性怪兽解放作为代价。
function c34923554.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段，确认自己场上是否存在至少1只满足cfilter条件（机械族·地属性且解放后有空位）的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c34923554.cfilter,1,nil,tp) end
	-- 选择1只满足条件的机械族·地属性怪兽作为解放素材。
	local g=Duel.SelectReleaseGroup(tp,c34923554.cfilter,1,1,nil,tp)
	-- 将选择的怪兽解放，作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- sptg为①效果发动时的目标判定函数：确认这张卡自身能够从手卡以表侧守备表示特殊召唤。
function c34923554.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息，将这张卡登记为本次效果预定特殊召唤的对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- spop为①效果处理时的操作函数：若这张卡仍与效果关联，则将其从手卡守备表示特殊召唤。
function c34923554.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 实际执行特殊召唤，将这张卡以表侧守备表示特殊召唤到持有者场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 定义筛选函数thcfilter，用于检查作为②效果除外代价的墓地怪兽是否满足机械族且可作为代价除外。
function c34923554.thcfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- thcost为②效果的代价函数：确认墓地存在符合条件的机械族怪兽后，选择1只除外作为代价。
function c34923554.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段，确认自己墓地是否存在至少1张机械族怪兽且可以作为代价除外。
	if chk==0 then return Duel.IsExistingMatchingCard(c34923554.thcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出提示，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足条件的机械族怪兽作为除外代价。
	local g=Duel.SelectMatchingCard(tp,c34923554.thcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义筛选函数thfilter，检查卡组中的卡是否为「超信地旋回」（卡号22866836）且能够加入手卡。
function c34923554.thfilter(c)
	return c:IsAbleToHand() and c:IsCode(22866836)
end
-- thtg为②效果的目标判定函数：确认卡组存在可检索的「超信地旋回」，并设置操作信息。
function c34923554.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标检测阶段，确认卡组是否存在至少1张满足thfilter条件的「超信地旋回」。
	if chk==0 then return Duel.IsExistingMatchingCard(c34923554.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，声明本次效果将从卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- thop为②效果处理时的操作函数：从卡组选1张「超信地旋回」加入手卡，并让对手确认。
function c34923554.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出提示，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的「超信地旋回」。
	local g=Duel.SelectMatchingCard(tp,c34923554.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入持有者手卡，原因为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的「超信地旋回」展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
