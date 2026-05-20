--光学迷彩アーマー
-- 效果：
-- 只能给1星的怪兽装备。装备这张卡的怪兽可以对对方进行直接攻击。
function c44762290.initial_effect(c)
	-- 只能给1星的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c44762290.target)
	e1:SetOperation(c44762290.operation)
	c:RegisterEffect(e1)
	-- 装备这张卡的怪兽可以对对方进行直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c44762290.dircon)
	c:RegisterEffect(e2)
	-- 只能给1星的怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c44762290.eqlimit)
	c:RegisterEffect(e3)
end
-- 装备限制：只能装备在1星怪兽身上
function c44762290.eqlimit(e,c)
	return c:IsLevel(1)
end
-- 过滤条件：场上表侧表示的1星怪兽
function c44762290.filter(c)
	return c:IsFaceup() and c:IsLevel(1)
end
-- 卡片发动时的目标选择与效果处理
function c44762290.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c44762290.filter(chkc) end
	-- 检查场上是否存在可作为装备对象的表侧表示1星怪兽
	if chk==0 then return Duel.IsExistingTarget(c44762290.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的1星怪兽作为装备对象
	Duel.SelectTarget(tp,c44762290.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将此卡作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 卡片发动后的效果处理：执行装备操作
function c44762290.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 直接攻击效果的适用条件：装备怪兽由当前玩家控制
function c44762290.dircon(e)
	return e:GetHandler():GetEquipTarget():GetControler()==e:GetHandlerPlayer()
end
