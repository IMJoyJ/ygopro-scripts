--スーペルヴィス
-- 效果：
-- 二重怪兽才能装备。
-- ①：装备怪兽当作再1次召唤的状态使用。
-- ②：表侧表示的这张卡从场上送去墓地的场合，以自己墓地1只通常怪兽为对象发动。那只怪兽特殊召唤。
function c95750695.initial_effect(c)
	-- 二重怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c95750695.target)
	e1:SetOperation(c95750695.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽当作再1次召唤的状态使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DUAL_STATUS)
	c:RegisterEffect(e2)
	-- 二重怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c95750695.eqlimit)
	c:RegisterEffect(e3)
	-- ②：表侧表示的这张卡从场上送去墓地的场合，以自己墓地1只通常怪兽为对象发动。那只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(95750695,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c95750695.spcon)
	e4:SetTarget(c95750695.sptg)
	e4:SetOperation(c95750695.spop)
	c:RegisterEffect(e4)
end
c95750695.has_text_type=TYPE_DUAL
-- 装备限制：只能装备于二重怪兽
function c95750695.eqlimit(e,c)
	return c:IsType(TYPE_DUAL)
end
-- 过滤条件：场上表侧表示的二重怪兽
function c95750695.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL)
end
-- 装备卡发动时的效果处理：选择场上1只表侧表示的二重怪兽为对象
function c95750695.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c95750695.filter(chkc) end
	-- 检查场上是否存在可以装备的表侧表示二重怪兽
	if chk==0 then return Duel.IsExistingTarget(c95750695.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的二重怪兽作为装备对象
	Duel.SelectTarget(tp,c95750695.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果分类为装备，操作信息为这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡发动成功后的效果处理：将这张卡装备给目标怪兽
function c95750695.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 触发条件：表侧表示的这张卡从场上送去墓地
function c95750695.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：自己墓地可以特殊召唤的通常怪兽
function c95750695.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备：选择自己墓地1只通常怪兽为对象
function c95750695.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c95750695.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只通常怪兽作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,c95750695.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果分类为特殊召唤，操作信息为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的实际处理：将目标怪兽特殊召唤
function c95750695.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的特殊召唤目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
