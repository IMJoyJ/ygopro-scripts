--魔菌
-- 效果：
-- 植物族才能装备。1只装备怪兽的攻击力·守备力上升300。
function c39774685.initial_effect(c)
	-- 装备魔法卡的发动效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c39774685.target)
	e1:SetOperation(c39774685.operation)
	c:RegisterEffect(e1)
	-- 1只装备怪兽的攻击力上升300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 1只装备怪兽的守备力上升300
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 植物族才能装备
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c39774685.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备对象必须为植物族
function c39774685.eqlimit(e,c)
	return c:IsRace(RACE_PLANT)
end
-- 筛选场上正面表示的植物族怪兽
function c39774685.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 设置效果目标，选择一只场上正面表示的植物族怪兽
function c39774685.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c39774685.filter(chkc) end
	-- 检查是否有符合条件的怪兽可作为装备对象
	if chk==0 then return Duel.IsExistingTarget(c39774685.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一只场上正面表示的植物族怪兽作为装备对象
	Duel.SelectTarget(tp,c39774685.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，记录装备对象
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡的处理效果
function c39774685.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
