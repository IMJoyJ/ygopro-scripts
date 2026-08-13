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
	-- 设置②效果的发动代价为把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c28762303.spcon)
	e2:SetTarget(c28762303.sptg)
	e2:SetOperation(c28762303.spop)
	c:RegisterEffect(e2)
end
-- ①效果的代价函数：检查并执行丢弃1张手卡作为发动代价。
function c28762303.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手牌中存在1张以上可以送去墓地的卡，以支付“把1张手卡送去墓地”的代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：从手卡选择1张卡丢弃去墓地，作为发动①效果的代价。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- ①效果的特殊召唤对象筛选条件：该怪兽需为水属性，且能被当前效果特殊召唤。
function c28762303.spfilter1(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动目标处理：确认发动条件（有空位、自身可送墓、墓地有对象），并从墓地选择1只水属性怪兽作为特殊召唤对象。
function c28762303.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c28762303.spfilter1(chkc,e,tp) end
	-- 发动条件检查：确认自己场上有可用的怪兽区（用于特殊召唤）且这张卡能够送去墓地。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0 and e:GetHandler():IsAbleToGrave()
		-- 发动条件检查：确认自己墓地存在至少1只满足条件的水属性怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c28762303.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示“请选择要特殊召唤的卡”的提示消息，供玩家选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地的水属性怪兽中选择1只作为效果对象，并将其登记为连锁对象。
	local g=Duel.SelectTarget(tp,c28762303.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：效果处理时会将这张卡送去墓地，登记CATEGORY_TOGRAVE。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	-- 设置操作信息：效果处理时会特殊召唤选择的对象怪兽，登记CATEGORY_SPECIAL_SUMMON。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将这张卡从场上送去墓地，若成功送墓且该卡在墓地，则将对象怪兽特殊召唤。
function c28762303.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，确认这张卡与效果仍有关联后，将其送去墓地，并确认送墓成功且位于墓地。
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 获取发动时选择的对象怪兽。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将对象怪兽以表侧表示特殊召唤到自己的怪兽区。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果触发条件的过滤器：判断被破坏的怪兽是否曾由自己控制、在被破坏前位于怪兽区且表侧表示、属性为水属性，并且被战斗或效果破坏。
function c28762303.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsAttribute(ATTRIBUTE_WATER) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ②效果的发动条件：本组被破坏的怪兽中存在满足条件的自己场上的表侧表示水属性怪兽，且不包含墓地中的这张卡自身。
function c28762303.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28762303.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②效果可特殊召唤怪兽的筛选条件：该怪兽是「冰水」怪兽，不是「冰水之阳起石灵」，且能被当前效果特殊召唤。
function c28762303.spfilter(c,e,tp)
	return c:IsSetCard(0x16c) and not c:IsCode(28762303) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标处理：确认自己场上有空位，且手卡·墓地存在符合条件的「冰水」怪兽，然后设置特殊召唤的操作信息。
function c28762303.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己场上有可用的怪兽区，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：确认手卡或墓地中存在至少1只符合条件且不是自身的「冰水」怪兽可特殊召唤。
		and Duel.IsExistingMatchingCard(c28762303.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置操作信息：效果处理时将进行特殊召唤，候选区域为手卡和墓地，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果处理：选择手卡·墓地的1只符合条件的「冰水」怪兽并特殊召唤到自己场上。
function c28762303.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认场上是否有可用怪兽区，若没有则本次处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 显示“请选择要特殊召唤的卡”的提示消息，供玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只满足条件且不受王家长眠之谷影响的「冰水」怪兽，作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28762303.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「冰水」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
