--水精鱗－サラキアビス
-- 效果：
-- 鱼族·海龙族·水族怪兽2只
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡所连接区的怪兽的攻击力·守备力上升500。
-- ②：对方回合把1张手卡送去墓地才能发动。从卡组把1只「水精鳞」怪兽加入手卡。
-- ③：这张卡被对方怪兽的攻击或者对方的效果破坏的场合，从卡组把1只水属性怪兽送去墓地，以自己墓地1只水属性怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c23545031.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2只满足鱼族·海龙族·水族种族的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_AQUA+RACE_FISH+RACE_SEASERPENT),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡所连接区的怪兽的攻击力·守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c23545031.indtg)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：对方回合把1张手卡送去墓地才能发动。从卡组把1只「水精鳞」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23545031,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,23545031)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCondition(c23545031.thcon)
	e3:SetCost(c23545031.thcost)
	e3:SetTarget(c23545031.thtg)
	e3:SetOperation(c23545031.thop)
	c:RegisterEffect(e3)
	-- ③：这张卡被对方怪兽的攻击或者对方的效果破坏的场合，从卡组把1只水属性怪兽送去墓地，以自己墓地1只水属性怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(23545031,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,23545032)
	e4:SetCondition(c23545031.spcon)
	e4:SetCost(c23545031.spcost)
	e4:SetTarget(c23545031.sptg)
	e4:SetOperation(c23545031.spop)
	c:RegisterEffect(e4)
end
-- 判断目标怪兽是否在连接区的怪兽组中
function c23545031.indtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 判断是否为对方回合
function c23545031.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 支付手卡1张送去墓地的费用
function c23545031.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在可送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃手卡1张送去墓地
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 筛选卡组中满足水精鳞系列、怪兽类型且可加入手牌的卡
function c23545031.thfilter(c)
	return c:IsSetCard(0x74) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索水精鳞怪兽的效果目标
function c23545031.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的水精鳞怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c23545031.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索水精鳞怪兽并加入手牌的效果
function c23545031.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择满足条件的1张水精鳞怪兽
	local g=Duel.SelectMatchingCard(tp,c23545031.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断此卡是否被对方破坏
function c23545031.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp)
		-- 判断此卡是否被对方效果破坏或被对方怪兽攻击破坏
		and (c:IsReason(REASON_EFFECT) and rp==1-tp or c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
end
-- 筛选卡组中满足水属性且可送去墓地的卡
function c23545031.spcfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGraveAsCost()
end
-- 支付卡组1张水属性怪兽送去墓地的费用
function c23545031.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c23545031.spcfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择满足条件的1张水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c23545031.spcfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 筛选墓地中满足水属性且可特殊召唤的怪兽
function c23545031.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置特殊召唤水属性怪兽的效果目标
function c23545031.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23545031.spfilter(chkc,e,tp) end
	-- 检查墓地是否存在满足条件的水属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c23545031.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择满足条件的1只水属性怪兽
	local g=Duel.SelectTarget(tp,c23545031.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤水属性怪兽的效果
function c23545031.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
