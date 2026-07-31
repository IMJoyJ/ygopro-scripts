--無限と有限のアルス＝マグナ
local s,id,o=GetID()
-- 创建并注册三个效果，分别为手牌起动检索效果、除外区特殊召唤效果和场上的除外效果。
function s.initial_effect(c)
	-- 手牌起动效果：支付1张手牌的除外作为cost，检索满足条件的卡加入手牌。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 除外区触发效果：当有融合或连接怪兽特殊召唤成功时，可将自身特殊召唤到场上。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 场上的除外效果：支付1次使用限制，选择场上1只怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.rmcon1)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(s.rmcon2)
	c:RegisterEffect(e4)
end
-- 检索效果的cost处理，将自身从手牌除外作为费用。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	-- 将自身从手牌除外作为费用。
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
-- 定义检索卡牌的过滤条件，非战士族、神代卡组、怪兽类型且能加入手牌。
function s.thfilter(c)
	return not c:IsRace(RACE_WARRIOR) and c:IsSetCard(0x1e6) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的目标，检查场上是否存在满足条件的卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查场上是否存在满足条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为检索卡牌到手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果的操作，选择一张卡加入手牌并确认对方查看。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从牌组中选择满足条件的一张卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g and g:GetCount()>0 then
		-- 将选中的卡送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认查看送入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 创建一个场上的效果，使神代连接怪兽的攻击力变为3倍。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(s.atkval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该攻击力提升效果到场上。
	Duel.RegisterEffect(e1,tp)
end
-- 定义攻击力提升效果的目标条件，为神代卡组且为连接怪兽。
function s.atktg(e,c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK)
end
-- 定义攻击力提升效果的计算方式，为原本攻击力的3倍。
function s.atkval(e,c)
	return c:GetBaseAttack()*3
end
-- 定义特殊召唤条件中所使用的过滤函数，为场上存在的融合或连接怪兽。
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_LINK)
end
-- 判断是否有融合或连接怪兽被特殊召唤成功。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler())
end
-- 设置特殊召唤效果的目标，检查是否有足够的召唤位置。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤效果的操作，将自身特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自身以0召唤方式特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义除外效果的条件中所使用的过滤函数，为场上的神代连接怪兽。
function s.confilter(c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK) and c:IsFaceup()
end
-- 设置除外效果的发动条件，非二速效果且场上存在神代连接怪兽。
function s.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该卡是否不能变成二速效果。
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,37279096)
		-- 检查场上是否存在满足条件的神代连接怪兽。
		and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置除外效果的发动条件，为二速效果且场上存在神代连接怪兽。
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该卡是否可以变成二速效果。
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,37279096)
		-- 检查场上是否存在满足条件的神代连接怪兽。
		and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置除外效果的目标，选择场上1只可除外的怪兽。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 检查场上是否存在可除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从场上选择1只怪兽作为除外目标。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为除外指定数量的卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外效果的操作，将目标怪兽除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 将目标怪兽以除外方式处理。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
