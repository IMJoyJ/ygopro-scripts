--ポセイドンの力
-- 效果：
-- 水族才能装备。1只装备怪兽的攻击力和守备力上升300。
function c77027445.initial_effect(c)
	-- 水族才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c77027445.target)
	e1:SetOperation(c77027445.operation)
	c:RegisterEffect(e1)
	-- 1只装备怪兽的攻击力...上升300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 1只装备怪兽的...守备力上升300
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 水族才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c77027445.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给水族怪兽
function c77027445.eqlimit(e,c)
	return c:IsRace(RACE_AQUA)
end
-- 过滤条件：场上表侧表示的水族怪兽
function c77027445.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA)
end
-- 效果发动的目标选择与处理：选择场上1只表侧表示的水族怪兽作为装备对象
function c77027445.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c77027445.filter(chkc) end
	-- 检查场上是否存在可以作为装备对象的水族怪兽
	if chk==0 then return Duel.IsExistingTarget(c77027445.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示的水族怪兽作为效果的对象
	Duel.SelectTarget(tp,c77027445.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将这张卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡装备给选择的怪兽
function c77027445.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的第一个对象（即要装备的怪兽）
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
