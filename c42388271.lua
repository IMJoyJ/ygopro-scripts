--星遺物－『星櫃』
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上的连接怪兽被对方的效果破坏送去自己墓地的场合，把这张卡从手卡送去墓地，以那1只连接怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
-- ③：通常召唤的这张卡在怪兽区域存在，对方从额外卡组把怪兽特殊召唤的场合才能发动。从卡组把1只怪兽送去墓地。
function c42388271.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：自己场上的连接怪兽被对方的效果破坏送去自己墓地的场合，把这张卡从手卡送去墓地，以那1只连接怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42388271,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,42388271)
	e1:SetCost(c42388271.spcost)
	e1:SetTarget(c42388271.sptg)
	e1:SetOperation(c42388271.spop)
	c:RegisterEffect(e1)
	-- ②：怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(c42388271.condition)
	c:RegisterEffect(e2)
	-- ③：通常召唤的这张卡在怪兽区域存在，对方从额外卡组把怪兽特殊召唤的场合才能发动。从卡组把1只怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42388271,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,42388272)
	e3:SetCondition(c42388271.tgcon)
	e3:SetTarget(c42388271.tgtg)
	e3:SetOperation(c42388271.tgop)
	c:RegisterEffect(e3)
end
function c42388271.condition(e,c)
	local ec=e:GetHandler()
	return ec:IsFaceup() or c:GetControler()==ec:GetControler()
end
function c42388271.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡从手卡送去墓地，作为效果的发动代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选被对方效果破坏的、自己场上表侧表示的连接怪兽：该怪兽被破坏送去自己墓地后，当前位于墓地且归属自己，能被这次效果取对象并能被特殊召唤。
function c42388271.spfilter(c,e,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0
		and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsType(TYPE_LINK)
		and c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()==1-tp
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件与取对象处理：当自己主要怪兽区有空位，且在诱发事件（本次送去墓地的怪兽）中存在满足spfilter的卡时，选择其中1只作为效果对象。
function c42388271.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c42388271.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的主要怪兽区域，以确定能否特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c42388271.spfilter,1,nil,e,tp) end
	-- 显示选择提示，要求玩家选择要特殊召唤的连接怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,c42388271.spfilter,1,1,nil,e,tp)
	-- 将选中的连接怪兽设定为本次连锁的对象，使该怪兽与效果建立联系。
	Duel.SetTargetCard(g)
	-- 设置操作信息，声明本效果将进行1次特殊召唤，对象为已选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理函数：在效果处理时，取出之前选择的对象，若该对象仍与效果关联，则将其特殊召唤。
function c42388271.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁中取得本效果的对象卡（即那只连接怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 由自己将对象怪兽以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选由对方（1-tp）从额外卡组特殊召唤成功的怪兽。
function c42388271.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- ③效果的发动条件：这张卡是通常召唤并在怪兽区域存在，且在本次特殊召唤成功的事件中存在对方从额外卡组特殊召唤的怪兽。
function c42388271.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL) and eg:IsExists(c42388271.cfilter,1,nil,1-tp)
end
-- 筛选卡组中可送去墓地的怪兽卡：满足怪兽卡类型且能够被送去墓地。
function c42388271.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ③效果的发动条件与操作信息登记：确认卡组中有1只可送去墓地的怪兽后，将效果信息登记为从卡组把1张卡送去墓地。
function c42388271.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在1张符合条件的可以送去墓地的怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c42388271.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本效果处理时将从卡组把1张卡送去墓地（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理函数：从卡组选择1只怪兽并送去墓地，若选择成功则执行。
function c42388271.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，要求玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张满足tgfilter的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c42388271.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽卡送去墓地，原因为效果（REASON_EFFECT）。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
