--電撃鞭
-- 效果：
-- 雷族才能装备。1只装备怪兽的攻击力·守备力上升300。
function c37820550.initial_effect(c)
	-- 雷族才能装备。1只装备怪兽的攻击力·守备力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c37820550.target)
	e1:SetOperation(c37820550.operation)
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
	-- 雷族才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c37820550.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备限制判定函数：只有雷族怪兽才能装备此卡
function c37820550.eqlimit(e,c)
	return c:IsRace(RACE_THUNDER)
end
-- 选择对象过滤条件：怪兽需为表侧表示且种族为雷族
function c37820550.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
-- 发动时的目标选择处理：确认场上有符合条件的雷族怪兽，提示玩家选择一只表侧表示的雷族怪兽作为装备对象，并设置操作信息
function c37820550.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37820550.filter(chkc) end
	-- 发动合法性检查：确认场上是否存在至少1只表侧表示且雷族的怪兽可供选择
	if chk==0 then return Duel.IsExistingTarget(c37820550.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示：请选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家从双方主要怪兽区选择1只表侧表示且雷族的怪兽作为装备对象（取对象效果）
	Duel.SelectTarget(tp,c37820550.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 记录本次连锁将进行装备卡装备操作，装备对象为发动效果的这张装备卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时：取得装备对象，确认装备卡和对象仍与效果关联且对象表侧表示，然后进行装备
function c37820550.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
