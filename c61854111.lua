--伝説の剣
-- 效果：
-- 战士族才能装备。1只装备怪兽的攻击力和守备力上升300。
function c61854111.initial_effect(c)
	-- 战士族才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c61854111.target)
	e1:SetOperation(c61854111.operation)
	c:RegisterEffect(e1)
	-- 1只装备怪兽的攻击力...上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 1只装备怪兽的...守备力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 战士族才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c61854111.eqlimit)
	c:RegisterEffect(e4)
end
-- 定义装备限制：只能装备在战士族怪兽上
function c61854111.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 过滤场上表侧表示的战士族怪兽
function c61854111.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 装备魔法卡发动时的目标选择与操作信息设置
function c61854111.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c61854111.filter(chkc) end
	-- 在发动时，检查场上是否存在可装备的表侧表示战士族怪兽
	if chk==0 then return Duel.IsExistingTarget(c61854111.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的战士族怪兽作为装备对象
	Duel.SelectTarget(tp,c61854111.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的效果处理
function c61854111.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
