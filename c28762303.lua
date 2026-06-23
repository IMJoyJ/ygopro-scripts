--氷水のティノーラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把1张手卡送去墓地，以自己墓地1只水属性怪兽为对象才能发动。场上的这张卡送去墓地，作为对象的怪兽特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的水属性怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从自己的手卡·墓地把「冰水之阳起石灵」以外的1只「冰水」怪兽特殊召唤。
function c28762303.initial_effect(c)
	-- ①：把1张手卡送去墓地，以自己墓地1只水属性怪兽为对象才能发动。场上的这张卡送去墓地，作为对象的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28762303,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,28762303)
	e1:SetCost(c28762303.spcost1)
	e1:SetTarget(c28762303.sptg1)
	e1:SetOperation(c28762303.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的水属性怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从自己的手卡·墓地把「冰水之阳起石灵」以外的1只「冰水」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28762303,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,28762304)
	-- 效果发动时把这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c28762303.spcon)
	e2:SetTarget(c28762303.sptg)
	e2:SetOperation(c28762303.spop)
	c:RegisterEffect(e2)
end
-- 效果发动时选择并丢弃1张手卡作为费用
function c28762303.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃1张手卡作为费用的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张手卡作为费用的操作
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 过滤满足条件的水属性怪兽
function c28762303.spfilter1(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时选择目标怪兽
function c28762303.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c28762303.spfilter1(chkc,e,tp) end
	-- 检查场上是否有空怪兽区
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0 and e:GetHandler():IsAbleToGrave()
		-- 检查自己墓地是否有满足条件的怪兽
		and Duel.IsExistingTarget(c28762303.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c28762303.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时将此卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	-- 设置效果处理时特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时将此卡送去墓地并特殊召唤目标怪兽
function c28762303.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡是否还在场上且已送去墓地
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 获取效果选择的目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将目标怪兽特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤被破坏的水属性怪兽
function c28762303.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsAttribute(ATTRIBUTE_WATER) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 判断是否满足效果发动条件
function c28762303.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28762303.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤满足条件的「冰水」怪兽
function c28762303.spfilter(c,e,tp)
	return c:IsSetCard(0x16c) and not c:IsCode(28762303) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时检查是否满足特殊召唤条件
function c28762303.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(c28762303.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置效果处理时特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理时选择并特殊召唤怪兽
function c28762303.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28762303.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
