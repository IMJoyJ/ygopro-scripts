--猛獣の歯
-- 效果：
-- 兽族才能装备。1只装备怪兽的攻击力和守备力上升300。
function c46009906.initial_effect(c)
	-- 装备魔法卡的发动效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c46009906.target)
	e1:SetOperation(c46009906.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 装备怪兽的守备力上升300
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 兽族才能装备
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c46009906.eqlimit)
	c:RegisterEffect(e4)
end
-- 检查目标怪兽是否为兽族
function c46009906.eqlimit(e,c)
	return c:IsRace(RACE_BEAST)
end
-- 筛选场上正面表示的兽族怪兽
function c46009906.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
-- 选择装备对象怪兽
function c46009906.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c46009906.filter(chkc) end
	-- 判断是否有符合条件的装备对象
	if chk==0 then return Duel.IsExistingTarget(c46009906.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只场上正面表示的兽族怪兽作为装备对象
	Duel.SelectTarget(tp,c46009906.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡的处理效果
function c46009906.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
