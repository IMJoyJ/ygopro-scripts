--S－Force ラプスウェル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以「治安战警队 拉普斯韦妖」以外的自己墓地1只「治安战警队」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：从手卡把1张「治安战警队」卡除外才能发动。自己的「治安战警队」怪兽的正对面的对方怪兽全部破坏。
function c27383719.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合，以「治安战警队 拉普斯韦妖」以外的自己墓地1只「治安战警队」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27383719,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,27383719)
	e1:SetTarget(c27383719.sptg)
	e1:SetOperation(c27383719.spop)
	c:RegisterEffect(e1)
	-- ②：从手卡把1张「治安战警队」卡除外才能发动。自己的「治安战警队」怪兽的正对面的对方怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(27383719,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,27383720)
	e2:SetCost(c27383719.descost)
	e2:SetTarget(c27383719.destg)
	e2:SetOperation(c27383719.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地中的怪兽是否为「治安战警队」卡组且不是自身，并且可以被特殊召唤。
function c27383719.spfilter(c,e,tp)
	return c:IsSetCard(0x156) and not c:IsCode(27383719)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标选择函数，用于选择满足条件的墓地怪兽作为特殊召唤对象。
function c27383719.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27383719.filter(chkc,e,tp) end
	-- 检查是否场上存在可用怪兽区，用于判断是否可以发动特殊召唤效果。
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		-- 检查是否在墓地中存在满足条件的「治安战警队」怪兽，用于判断是否可以发动特殊召唤效果。
		and Duel.IsExistingTarget(c27383719.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤对象。
	local g=Duel.SelectTarget(tp,c27383719.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，表示将要特殊召唤一只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果的操作函数，将选中的怪兽特殊召唤到场上。
function c27383719.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断手牌或墓地中的卡是否为「治安战警队」卡组且可以作为除外的代价。
function c27383719.costfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x156) and c:IsAbleToRemoveAsCost()
	else
		return e:GetHandler():IsSetCard(0x156) and c:IsHasEffect(55049722,tp) and c:IsAbleToRemoveAsCost()
	end
end
-- 处理效果的除外代价函数，选择一张「治安战警队」卡除外。
function c27383719.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否手牌或墓地中存在满足条件的「治安战警队」卡，用于判断是否可以支付除外代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c27383719.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的卡作为除外代价。
	local tg=Duel.SelectMatchingCard(tp,c27383719.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local te=tg:GetFirst():IsHasEffect(55049722,tp)
	if te then
		te:UseCountLimit(tp)
		-- 以代替方式将选中的卡除外。
		Duel.Remove(tg,POS_FACEUP,REASON_REPLACE)
	else
		-- 以代价方式将选中的卡除外。
		Duel.Remove(tg,POS_FACEUP,REASON_COST)
	end
end
-- 过滤函数，用于判断场上正面表示的怪兽是否为「治安战警队」卡组。
function c27383719.ggfilter(c,tp)
	return c:IsSetCard(0x156) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 过滤函数，用于判断对方场上的怪兽是否在己方「治安战警队」怪兽的正对面。
function c27383719.desfilter(c,tp)
	local g=c:GetColumnGroup()
	return g:IsExists(c27383719.ggfilter,1,nil,tp)
end
-- 设置破坏效果的目标选择函数，用于选择满足条件的对方怪兽。
function c27383719.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的对方怪兽组。
	local g=Duel.GetMatchingGroup(c27383719.desfilter,tp,0,LOCATION_MZONE,nil,tp)
	if chk==0 then return #g>0 end
	-- 设置效果操作信息，表示将要破坏若干怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 处理破坏效果的操作函数，将选中的对方怪兽破坏。
function c27383719.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的对方怪兽组。
	local g=Duel.GetMatchingGroup(c27383719.desfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 将满足条件的对方怪兽破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
