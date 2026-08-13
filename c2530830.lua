--銀河眼の光波刃竜
-- 效果：
-- 9星怪兽×3
-- 这张卡也能在自己场上的8阶「银河眼」超量怪兽上面重叠来超量召唤。这张卡不能作为超量召唤的素材。
-- ①：1回合1次，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：超量召唤的这张卡被对方怪兽的攻击或者对方的效果破坏送去墓地的场合，以自己墓地1只「银河眼光波龙」为对象才能发动。那只怪兽特殊召唤。
function c2530830.initial_effect(c)
	aux.AddXyzProcedure(c,nil,9,3,c2530830.ovfilter,aux.Stringid(2530830,0))  --"是否在「银河眼」超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 这张卡不能作为超量召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2530830,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c2530830.descost)
	e2:SetTarget(c2530830.destg)
	e2:SetOperation(c2530830.desop)
	c:RegisterEffect(e2)
	-- ②：超量召唤的这张卡被对方怪兽的攻击或者对方的效果破坏送去墓地的场合，以自己墓地1只「银河眼光波龙」为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2530830,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(c2530830.condition)
	e3:SetTarget(c2530830.target)
	e3:SetOperation(c2530830.operation)
	c:RegisterEffect(e3)
end
-- 判定这张卡能否重叠在自己场上表侧表示的8阶「银河眼」超量怪兽上面进行超量召唤：需满足表侧表示、属于「银河眼」字段、超量怪兽且阶级为8。
function c2530830.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107b) and c:IsType(TYPE_XYZ) and c:IsRank(8)
end
-- 发动①效果时，需要取除这张卡的1个超量素材作为代价；检查是否有素材，若有则移除1个。
function c2530830.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的发动目标处理：选择场上任意1张卡作为对象；检查是否存在可选择的卡，并提示选择要破坏的卡，选定后设置破坏操作信息。
function c2530830.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 效果发动合法性检查：确认场上存在至少1张可作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示选择提示，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 向连锁登记此次破坏效果的对象与数量，供后续处理及被干扰时判断。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果的解决时处理：若选择的对象仍与效果相关，则将其破坏。
function c2530830.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果的发动条件判定：这张卡是以超量召唤方式出场，且在被对方怪兽攻击或对方效果破坏时从自己主要怪兽区送去墓地。
function c2530830.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
		-- 具体判定破坏来源：由对方发动的效果（效果控制者为对方）或对方怪兽的战斗破坏（攻击怪兽的控制者为对方）导致。
		and (c:IsReason(REASON_EFFECT) and rp==1-tp or c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
		and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 目标过滤函数：选择的对象必须是卡号为18963306的「银河眼光波龙」，且可以被当前效果特殊召唤。
function c2530830.filter(c,e,tp)
	return c:IsCode(18963306) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标处理：确认自己主要怪兽区有空位，且墓地存在符合条件的「银河眼光波龙」，然后选择1只为对象并设置特殊召唤操作信息。
function c2530830.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2530830.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的主要怪兽区空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足过滤器条件的目标怪兽。
		and Duel.IsExistingTarget(c2530830.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「银河眼光波龙」作为效果对象。
	local g=Duel.SelectTarget(tp,c2530830.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向连锁登记此次特殊召唤操作的信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的解决时处理：若选择的对象仍与效果相关，则将其以表侧表示特殊召唤到自己场上。
function c2530830.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取回发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
