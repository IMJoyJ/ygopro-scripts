--水精鱗－サラキアビス
-- 效果：
-- 鱼族·海龙族·水族怪兽2只
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡所连接区的怪兽的攻击力·守备力上升500。
-- ②：对方回合把1张手卡送去墓地才能发动。从卡组把1只「水精鳞」怪兽加入手卡。
-- ③：这张卡被对方怪兽的攻击或者对方的效果破坏的场合，从卡组把1只水属性怪兽送去墓地，以自己墓地1只水属性怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c23545031.initial_effect(c)
	-- 为这张卡添加连接召唤手续：连接素材为2只鱼族·海龙族·水族怪兽（必须正好2只）。
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
-- 判断怪兽c是否位于这张卡的连接区，作为①效果攻击力·守备力上升的适用对象。
function c23545031.indtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- ②效果的发动条件：当前回合玩家不是这张卡的控制者tp，即在对方回合才能发动。
function c23545031.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家不等于tp，满足对方回合条件。
	return Duel.GetTurnPlayer()~=tp
end
-- ②效果的发动代价：从手卡丢弃1张卡作为cost；包含cost可用性判断与实际丢弃处理。
function c23545031.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost可行性检查：确认手卡中存在至少1张能作为cost送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行cost：选择并丢弃1张手卡（REASON_COST作为代价）。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 检索过滤条件：卡名含有「水精鳞」的怪兽卡，并且能够加入手卡。
function c23545031.thfilter(c)
	return c:IsSetCard(0x74) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动时目标设定：确认卡组存在符合条件的「水精鳞」怪兽，并设置从卡组检索加入手卡的操作信息。
function c23545031.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只符合thfilter条件的「水精鳞」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c23545031.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时从卡组把1张卡加入手卡（检索目标在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实际处理：从卡组选择1只「水精鳞」怪兽加入手卡，并向对手确认加入手卡的卡。
function c23545031.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c23545031.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的发动条件：这张卡被对方怪兽的战斗破坏或对方效果破坏，且破坏时控制权属于自己（tp）。
function c23545031.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp)
		-- 判断破坏来源：被对方的效果破坏（rp=1-tp）或对方怪兽战斗破坏（攻击者控制者为1-tp）。
		and (c:IsReason(REASON_EFFECT) and rp==1-tp or c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
end
-- cost送墓过滤条件：卡组中的水属性怪兽，且能作为cost送去墓地。
function c23545031.spcfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGraveAsCost()
end
-- ③效果的发动代价：从卡组把1只水属性怪兽送去墓地；包含cost可行性检查与实际送墓操作。
function c23545031.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost可行性检查：确认卡组中存在至少1只能作为cost送去墓地的水属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c23545031.spcfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张满足spcfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c23545031.spcfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡送去墓地（REASON_COST作为代价）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 特殊召唤对象过滤条件：自己墓地的水属性怪兽，且可以表侧守备表示特殊召唤。
function c23545031.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ③效果的取对象处理：选择自己墓地1只水属性怪兽作为对象，并设置特殊召唤的操作信息。
function c23545031.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23545031.spfilter(chkc,e,tp) end
	-- 取对象前检查：自己墓地是否存在至少1只符合spfilter条件的水属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(c23545031.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只水属性怪兽作为效果对象（并使其与效果关联）。
	local g=Duel.SelectTarget(tp,c23545031.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将选择的怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果的实际处理：效果适用时，若对象仍与效果关联，将其守备表示特殊召唤。
function c23545031.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁的对象卡（之前选择的特殊召唤目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到tp的场上（进行召唤条件/苏生限制检查）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
