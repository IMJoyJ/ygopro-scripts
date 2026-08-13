--漆黒の名馬
-- 效果：
-- 名字带有「六武众」的怪兽才能装备。装备怪兽的攻击力·守备力上升200。装备怪兽被破坏的场合，这张卡代替破坏。
function c12324546.initial_effect(c)
	-- 名字带有「六武众」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c12324546.target)
	e1:SetOperation(c12324546.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(200)
	c:RegisterEffect(e2)
	-- 装备怪兽的守备力上升200。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(200)
	c:RegisterEffect(e3)
	-- 装备怪兽被破坏的场合，这张卡代替破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 名字带有「六武众」的怪兽才能装备。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c12324546.eqlimit)
	c:RegisterEffect(e5)
end
-- 判断怪兽是否为名字带有「六武众」的怪兽，作为此卡装备对象的限制条件。
function c12324546.eqlimit(e,c)
	return c:IsSetCard(0x103d)
end
-- 装备目标筛选：选择表侧表示且名字带有「六武众」的怪兽。
function c12324546.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 装备魔法发动时的目标处理：选择双方场上1只表侧表示的名字带有「六武众」的怪兽作为装备对象，并登记装备操作信息。
function c12324546.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c12324546.filter(chkc) end
	-- 发动时判定：场上是否存在满足条件的表侧表示「六武众」怪兽，若不存在则无法发动。
	if chk==0 then return Duel.IsExistingTarget(c12324546.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示：“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让当前玩家从自己和对方场上选择1只表侧表示的名字带有「六武众」的怪兽作为装备对象。
	Duel.SelectTarget(tp,c12324546.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：本连锁将进行装备（CATEGORY_EQUIP），对象为此卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡和目标怪兽均与效果相关且目标仍为表侧表示，则将此卡装备给目标怪兽。
function c12324546.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
