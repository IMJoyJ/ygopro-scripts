--フォロー・ウィンド
-- 效果：
-- 鸟兽族怪兽可以装备。装备怪兽的攻击力·守备力上升300。
function c98252586.initial_effect(c)
	-- 鸟兽族怪兽可以装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c98252586.target)
	e1:SetOperation(c98252586.operation)
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
	-- 鸟兽族怪兽可以装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c98252586.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备限制：仅限鸟兽族怪兽
function c98252586.eqlimit(e,c)
	return c:IsRace(RACE_WINDBEAST)
end
-- 过滤条件：场上表侧表示的鸟兽族怪兽
function c98252586.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WINDBEAST)
end
-- 效果发动的目标选择与处理
function c98252586.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c98252586.filter(chkc) end
	-- 检查场上是否存在可选的表侧表示鸟兽族怪兽
	if chk==0 then return Duel.IsExistingTarget(c98252586.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的鸟兽族怪兽作为对象
	Duel.SelectTarget(tp,c98252586.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：此效果包含装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡装备给目标怪兽
function c98252586.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
