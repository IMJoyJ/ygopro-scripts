--銀河眼の光波刃竜
-- 效果：
-- 9星怪兽×3
-- 这张卡也能在自己场上的8阶「银河眼」超量怪兽上面重叠来超量召唤。这张卡不能作为超量召唤的素材。
-- ①：1回合1次，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：超量召唤的这张卡被对方怪兽的攻击或者对方的效果破坏送去墓地的场合，以自己墓地1只「银河眼光波龙」为对象才能发动。那只怪兽特殊召唤。
function c2530830.initial_effect(c)
	aux.AddXyzProcedure(c,nil,9,3,c2530830.ovfilter,aux.Stringid(2530830,0))  --"是否在「银河眼」超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ②：超量召唤的这张卡被对方怪兽的攻击或者对方的效果破坏送去墓地的场合，以自己墓地1只「银河眼光波龙」为对象才能发动。那只怪兽特殊召唤。
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
-- 检索满足条件的8阶「银河眼」超量怪兽，用于超量召唤
function c2530830.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107b) and c:IsType(TYPE_XYZ) and c:IsRank(8)
end
-- 支付1个超量素材作为cost
function c2530830.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 选择场上1张卡作为破坏对象
function c2530830.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 判断是否满足选择场上1张卡的条件
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作
function c2530830.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否满足效果发动条件
function c2530830.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
		-- 判断破坏原因是否为对方效果或攻击
		and (c:IsReason(REASON_EFFECT) and rp==1-tp or c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
		and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 检索满足条件的「银河眼光波龙」怪兽
function c2530830.filter(c,e,tp)
	return c:IsCode(18963306) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择墓地1只「银河眼光波龙」怪兽作为特殊召唤对象
function c2530830.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2530830.filter(chkc,e,tp) end
	-- 判断是否满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足选择墓地1只「银河眼光波龙」怪兽的条件
		and Duel.IsExistingTarget(c2530830.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只「银河眼光波龙」怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c2530830.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c2530830.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
