--竜魂の力
-- 效果：
-- 只有战士族可以装备。装备怪兽的种族变龙族，攻击力守备力上升500。
function c32437102.initial_effect(c)
	-- 装备怪兽的种族变龙族，攻击力守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c32437102.target)
	e1:SetOperation(c32437102.operation)
	c:RegisterEffect(e1)
	-- 攻击力守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 装备怪兽的种族变龙族。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CHANGE_RACE)
	e4:SetValue(RACE_DRAGON)
	c:RegisterEffect(e4)
	-- 只有战士族可以装备。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c32437102.eqlimit)
	c:RegisterEffect(e5)
end
-- 限制装备对象必须为战士族。
function c32437102.eqlimit(e,c)
	return c:GetOriginalRace()==RACE_WARRIOR
end
-- 筛选场上正面表示的战士族怪兽。
function c32437102.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 选择装备目标，筛选场上正面表示的战士族怪兽。
function c32437102.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c32437102.filter(chkc) end
	-- 判断是否存在符合条件的装备目标。
	if chk==0 then return Duel.IsExistingTarget(c32437102.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个场上正面表示的战士族怪兽作为装备对象。
	Duel.SelectTarget(tp,c32437102.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁操作为装备效果。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将此卡装备给选中的怪兽。
function c32437102.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
