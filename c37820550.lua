--電撃鞭
-- 效果：
-- 雷族才能装备。1只装备怪兽的攻击力·守备力上升300。
function c37820550.initial_effect(c)
	-- 雷族才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c37820550.target)
	e1:SetOperation(c37820550.operation)
	c:RegisterEffect(e1)
	-- 1只装备怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 1只装备怪兽的守备力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 雷族才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c37820550.eqlimit)
	c:RegisterEffect(e4)
end
-- 限制装备对象必须为雷族怪兽。
function c37820550.eqlimit(e,c)
	return c:IsRace(RACE_THUNDER)
end
-- 筛选场上正面表示的雷族怪兽。
function c37820550.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
-- 选择装备目标怪兽。
function c37820550.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37820550.filter(chkc) end
	-- 检查是否存在符合条件的装备目标。
	if chk==0 then return Duel.IsExistingTarget(c37820550.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一只场上正面表示的雷族怪兽作为装备对象。
	Duel.SelectTarget(tp,c37820550.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作。
function c37820550.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
