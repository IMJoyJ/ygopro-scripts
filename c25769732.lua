--機械改造工場
-- 效果：
-- 机械族怪兽可以装备。装备怪兽的攻击力·守备力上升300。
function c25769732.initial_effect(c)
	-- 装备怪兽的攻击力·守备力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c25769732.target)
	e1:SetOperation(c25769732.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击力·守备力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 机械族怪兽可以装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c25769732.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备对象必须为机械族怪兽
function c25769732.eqlimit(e,c)
	return c:IsRace(RACE_MACHINE)
end
-- 筛选场上正面表示的机械族怪兽
function c25769732.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 选择装备对象，筛选场上正面表示的机械族怪兽
function c25769732.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c25769732.filter(chkc) end
	-- 判断是否满足装备条件
	if chk==0 then return Duel.IsExistingTarget(c25769732.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个场上正面表示的机械族怪兽作为装备对象
	Duel.SelectTarget(tp,c25769732.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c25769732.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
