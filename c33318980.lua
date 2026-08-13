--暗黒騎士ガイアソルジャー
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把自己场上1只龙族融合怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
-- ②：这张卡特殊召唤成功的场合，以场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。
-- ③：把这张卡解放才能发动。从卡组把「暗黑骑士 盖亚战士」以外的1只7星以上的战士族怪兽加入手卡。
function c33318980.initial_effect(c)
	-- 这个卡名的①②③的效果1回合各能使用1次。①：把自己场上1只龙族融合怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33318980,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,33318980)
	e1:SetCost(c33318980.spcost)
	e1:SetTarget(c33318980.sptg)
	e1:SetOperation(c33318980.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，以场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33318980,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,33318981)
	e2:SetTarget(c33318980.postg)
	e2:SetOperation(c33318980.posop)
	c:RegisterEffect(e2)
	-- ③：把这张卡解放才能发动。从卡组把「暗黑骑士 盖亚战士」以外的1只7星以上的战士族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33318980,2))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,33318982)
	e3:SetCost(c33318980.thcost)
	e3:SetTarget(c33318980.thtg)
	e3:SetOperation(c33318980.thop)
	c:RegisterEffect(e3)
end
-- 定义解放素材的过滤条件：该怪兽必须是龙族融合怪兽，并且在解放它之后自己场上仍有空余的怪兽区可供此卡特殊召唤。
function c33318980.rfilter(c,tp)
	-- 判断怪兽是否为龙族融合怪兽，且将其解放后自己场上仍有可用的怪兽区空格。
	return Duel.GetMZoneCount(tp,c)>0 and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION)
end
-- ①效果的发动代价：从自己场上选择1只龙族融合怪兽解放才能发动。该函数完成代价的检查、选择与解放。
function c33318980.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足条件的龙族融合怪兽，且解放后有空位可供特殊召唤。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c33318980.rfilter,1,nil,tp) end
	-- 弹出选择提示，提示玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家从自己场上选择1只满足条件的龙族融合怪兽。
	local g=Duel.SelectReleaseGroup(tp,c33318980.rfilter,1,1,nil,tp)
	-- 将选择的怪兽解放，作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- ①效果的目标函数：确认这张卡能够被特殊召唤，并设置特殊召唤的操作信息。
function c33318980.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，标明本次效果处理会进行特殊召唤，对象为这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的操作函数：实际处理将这张卡从手卡特殊召唤。
function c33318980.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果对象过滤条件：怪兽必须是攻击表示，且能够变更表示形式。
function c33318980.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- ②效果的目标函数：选择场上1只攻击表示怪兽为对象，设定改变其表示形式的处理。
function c33318980.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c33318980.posfilter(chkc) end
	-- 检查场上是否存在至少1只攻击表示且可以变更表示形式的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c33318980.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上1只攻击表示怪兽作为效果对象。
	Duel.SelectTarget(tp,c33318980.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ②效果的操作函数：将对象怪兽变成守备表示。
function c33318980.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttackPos() then
		-- 将对象怪兽变为表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
-- ③效果的发动代价：解放这张卡才能发动。该函数检查并执行解放。
function c33318980.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放，作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义③效果检索的过滤条件：等级7以上、战士族、卡名不是「暗黑骑士 盖亚战士」本身、且可以加入手卡。
function c33318980.thfilter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_WARRIOR) and not c:IsCode(33318980) and c:IsAbleToHand()
end
-- ③效果的目标函数：检查卡组是否存在满足条件的怪兽，并设置加入手卡的操作信息。
function c33318980.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张满足条件的战士族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c33318980.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，标明本次效果处理时会从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果的操作函数：实际从卡组选择1张满足条件的战士族怪兽加入手牌，并给对方确认。
function c33318980.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足过滤条件的战士族怪兽。
	local g=Duel.SelectMatchingCard(tp,c33318980.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡出示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
