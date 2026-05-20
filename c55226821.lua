--稲妻の剣
-- 效果：
-- 战士族才可以装备。装备的怪兽的攻击力上升800。场上的全部水属性怪兽的攻击力下降500。
function c55226821.initial_effect(c)
	-- 战士族才可以装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c55226821.target)
	e1:SetOperation(c55226821.operation)
	c:RegisterEffect(e1)
	-- 装备的怪兽的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 战士族才可以装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c55226821.eqlimit)
	c:RegisterEffect(e3)
	-- 场上的全部水属性怪兽的攻击力下降500。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetTarget(c55226821.adtg)
	e4:SetValue(-500)
	c:RegisterEffect(e4)
end
-- 过滤场上的水属性怪兽
function c55226821.adtg(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
-- 限制装备卡只能装备给战士族怪兽
function c55226821.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 过滤场上表侧表示的战士族怪兽
function c55226821.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 装备魔法卡发动时的效果处理，确认是否能选择合法的装备对象并进行选择
function c55226821.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c55226821.filter(chkc) end
	-- 检查场上是否存在可以装备的表侧表示战士族怪兽
	if chk==0 then return Duel.IsExistingTarget(c55226821.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，要求选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的战士族怪兽作为效果的对象
	Duel.SelectTarget(tp,c55226821.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的效果处理，执行装备操作
function c55226821.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
