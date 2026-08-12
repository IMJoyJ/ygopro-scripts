--レーザー砲機甲鎧
-- 效果：
-- 昆虫族怪兽才能装备。装备怪兽的攻击力·守备力上升300。
function c77007920.initial_effect(c)
	-- 昆虫族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c77007920.target)
	e1:SetOperation(c77007920.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 昆虫族怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c77007920.eqlimit)
	c:RegisterEffect(e4)
end
-- 限制装备卡只能装备给昆虫族怪兽
function c77007920.eqlimit(e,c)
	return c:IsRace(RACE_INSECT)
end
-- 过滤场上表侧表示的昆虫族怪兽
function c77007920.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 装备魔法卡发动时的对象选择与发动准备
function c77007920.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c77007920.filter(chkc) end
	-- 在发动时，检查场上是否存在可以作为装备对象的表侧表示昆虫族怪兽
	if chk==0 then return Duel.IsExistingTarget(c77007920.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的昆虫族怪兽作为效果的对象
	Duel.SelectTarget(tp,c77007920.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的效果处理，执行装备操作
function c77007920.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
