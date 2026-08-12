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
-- 检查场上是否存在满足机械族·地属性且有可用怪兽区的怪兽
function c34923554.cfilter(c,tp)
	-- 满足机械族·地属性且有可用怪兽区
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的发动费用处理，检查并选择解放满足条件的怪兽
function c34923554.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽用于解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,c34923554.cfilter,1,nil,tp) end
	-- 选择1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c34923554.cfilter,1,1,nil,tp)
	-- 将选中的怪兽解放作为效果①的发动费用
	Duel.Release(g,REASON_COST)
end
-- 效果①的发动目标设定，确认卡片可以特殊召唤
function c34923554.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置效果①的发动信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的发动处理，将此卡特殊召唤到场上
function c34923554.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以守备表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 检查墓地是否存在满足机械族且为怪兽的可除外卡
function c34923554.thcfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动费用处理，检查并选择除外满足条件的怪兽
function c34923554.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在满足条件的怪兽用于除外
	if chk==0 then return Duel.IsExistingMatchingCard(c34923554.thcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的怪兽进行除外
	local g=Duel.SelectMatchingCard(tp,c34923554.thcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽除外作为效果②的发动费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检查卡组是否存在「超信地旋回」
function c34923554.thfilter(c)
	return c:IsAbleToHand() and c:IsCode(22866836)
end
-- 效果②的发动目标设定，确认可以将「超信地旋回」加入手牌
function c34923554.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在「超信地旋回」
	if chk==0 then return Duel.IsExistingMatchingCard(c34923554.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果②的发动信息，表示将把卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的发动处理，选择并把「超信地旋回」加入手牌
function c34923554.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张「超信地旋回」加入手牌
	local g=Duel.SelectMatchingCard(tp,c34923554.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
