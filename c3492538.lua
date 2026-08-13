--火器付機甲鎧
-- 效果：
-- 昆虫族怪兽才能装备。
-- ①：装备怪兽的攻击力上升700。
function c3492538.initial_effect(c)
	-- 昆虫族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c3492538.target)
	e1:SetOperation(c3492538.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升700。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	-- 昆虫族怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c3492538.eqlimit)
	c:RegisterEffect(e4)
end
-- 此函数作为EFFECT_EQUIP_LIMIT的判定函数：返回true时表示该装备卡可以装备给这张卡；此处限制装备对象必须为昆虫族怪兽，即只有昆虫族怪兽才能装备。
function c3492538.eqlimit(e,c)
	return c:IsRace(RACE_INSECT)
end
-- 筛选条件：怪兽需为表侧表示且为昆虫族，用于发动时选择装备对象的过滤。
function c3492538.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 装备魔法发动时的目标处理：检查是否存在符合条件的表侧昆虫族怪兽，若存在则提示玩家选择1只作为装备对象，并设置操作信息为装备。
function c3492538.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c3492538.filter(chkc) end
	-- 发动合法性检查：确认场上是否存在至少1只符合条件的表侧昆虫族怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c3492538.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，告知玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 在主要怪兽区选择1只符合条件的表侧昆虫族怪兽，并将其登记为这张装备卡的效果对象。
	Duel.SelectTarget(tp,c3492538.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明这张卡将进行装备，操作对象为这张装备卡本身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：取得之前选择的装备对象，若这张卡和对象仍与效果关联且对象表侧表示，则将这张卡装备给该昆虫族怪兽。
function c3492538.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动时选择装备的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备给选择的昆虫族怪兽，完成装备动作。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
