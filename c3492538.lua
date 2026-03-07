--火器付機甲鎧
-- 效果：
-- 昆虫族怪兽才能装备。
-- ①：装备怪兽的攻击力上升700。
function c3492538.initial_effect(c)
	-- ①：装备怪兽的攻击力上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c3492538.target)
	e1:SetOperation(c3492538.operation)
	c:RegisterEffect(e1)
	-- 昆虫族怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力上升700。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c3492538.eqlimit)
	c:RegisterEffect(e4)
end
-- 检查目标怪兽是否为昆虫族。
function c3492538.eqlimit(e,c)
	return c:IsRace(RACE_INSECT)
end
-- 检查怪兽是否为表侧表示且为昆虫族。
function c3492538.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 选择装备对象，要求为表侧表示的昆虫族怪兽。
function c3492538.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c3492538.filter(chkc) end
	-- 判断是否满足选择装备对象的条件。
	if chk==0 then return Duel.IsExistingTarget(c3492538.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个符合条件的怪兽作为装备对象。
	Duel.SelectTarget(tp,c3492538.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果的处理信息，表示将进行装备操作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给目标怪兽。
function c3492538.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
