--機械改造工場
-- 效果：
-- 机械族怪兽可以装备。装备怪兽的攻击力·守备力上升300。
function c25769732.initial_effect(c)
	-- 机械族怪兽可以装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c25769732.target)
	e1:SetOperation(c25769732.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 装备怪兽的守备力上升300。
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
-- 判断装备对象是否为机械族怪兽，只有机械族怪兽才能装备这张卡。
function c25769732.eqlimit(e,c)
	return c:IsRace(RACE_MACHINE)
end
-- 筛选满足条件的装备对象：场上表侧表示且为机械族的怪兽。
function c25769732.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 发动时的目标处理：选择场上1只表侧表示机械族怪兽作为这张卡的装备对象，并设置相关操作信息。
function c25769732.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c25769732.filter(chkc) end
	-- 发动合法性检查：确认场上是否存在1只符合条件的表侧表示机械族怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c25769732.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从场上选择1只表侧表示机械族怪兽，将其设置为这张卡的装备对象。
	Duel.SelectTarget(tp,c25769732.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，标明本次效果是将这张卡装备给对象（CATEGORY_EQUIP），供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡和目标对象仍与效果关联且目标为表侧表示，则将这张卡装备给目标怪兽。
function c25769732.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
