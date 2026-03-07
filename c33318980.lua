--暗黒騎士ガイアソルジャー
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把自己场上1只龙族融合怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
-- ②：这张卡特殊召唤成功的场合，以场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。
-- ③：把这张卡解放才能发动。从卡组把「暗黑骑士 盖亚战士」以外的1只7星以上的战士族怪兽加入手卡。
function c33318980.initial_effect(c)
	-- ①：把自己场上1只龙族融合怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
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
-- 用于筛选满足条件的龙族融合怪兽，确保其在场上存在可用怪兽区
function c33318980.rfilter(c,tp)
	-- 检查目标怪兽是否为龙族融合怪兽且场上存在可用怪兽区
	return Duel.GetMZoneCount(tp,c)>0 and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION)
end
-- 效果发动时检查是否满足解放条件并选择解放对象
function c33318980.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c33318980.rfilter,1,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的1张卡进行解放
	local g=Duel.SelectReleaseGroup(tp,c33318980.rfilter,1,1,nil,tp)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 设置特殊召唤的处理目标
function c33318980.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c33318980.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 用于筛选攻击表示且可改变表示形式的怪兽
function c33318980.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- 设置改变表示形式的效果目标
function c33318980.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c33318980.posfilter(chkc) end
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c33318980.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的怪兽进行表示形式改变
	Duel.SelectTarget(tp,c33318980.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 执行表示形式改变操作
function c33318980.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttackPos() then
		-- 将目标怪兽变为守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
-- 设置效果发动时的解放成本
function c33318980.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为发动成本
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 用于筛选满足条件的7星以上战士族怪兽
function c33318980.thfilter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_WARRIOR) and not c:IsCode(33318980) and c:IsAbleToHand()
end
-- 设置检索效果的处理目标
function c33318980.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c33318980.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果
function c33318980.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c33318980.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
