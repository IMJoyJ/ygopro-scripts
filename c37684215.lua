--融合武器ムラサメブレード
-- 效果：
-- 战士族怪兽才能装备。
-- ①：装备怪兽的攻击力上升800。
-- ②：给怪兽装备的这张卡不会被效果破坏。
function c37684215.initial_effect(c)
	-- 装备魔法卡的发动效果，可以自由连锁，需要选择一个战士族的表侧怪兽作为装备对象
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c37684215.target)
	e1:SetOperation(c37684215.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升800
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 战士族怪兽才能装备
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c37684215.eqlimit)
	c:RegisterEffect(e3)
	-- 给怪兽装备的这张卡不会被效果破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c37684215.indcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 判断装备对象是否为战士族
function c37684215.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 筛选表侧表示的战士族怪兽
function c37684215.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 设置效果目标为一个战士族的表侧怪兽，准备进行装备
function c37684215.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37684215.filter(chkc) end
	-- 检查是否有符合条件的战士族表侧怪兽可作为装备对象
	if chk==0 then return Duel.IsExistingTarget(c37684215.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个战士族表侧怪兽作为装备对象
	Duel.SelectTarget(tp,c37684215.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给目标怪兽
function c37684215.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断装备卡是否已装备怪兽，若已装备则生效
function c37684215.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
