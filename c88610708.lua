--シールドバッシュ
-- 效果：
-- 通常召唤的怪兽才能装备。
-- ①：装备怪兽的攻击力上升1000。
-- ②：装备怪兽的战斗发生的对自己的战斗伤害变成0。
function c88610708.initial_effect(c)
	-- 通常召唤的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c88610708.target)
	e1:SetOperation(c88610708.operation)
	c:RegisterEffect(e1)
	-- 通常召唤的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c88610708.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	-- ②：装备怪兽的战斗发生的对自己的战斗伤害变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e4:SetCondition(c88610708.damcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 装备限制：判定怪兽是否为通常召唤的怪兽
function c88610708.eqlimit(e,c)
	return c:IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 过滤条件：场上表侧表示且是通常召唤的怪兽
function c88610708.filter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 魔法卡发动时的对象选择与效果处理
function c88610708.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c88610708.filter(chkc) end
	-- 判定场上是否存在符合装备条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c88610708.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c88610708.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 魔法卡发动成功后的效果处理，执行装备操作
function c88610708.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 伤害免除效果的适用条件：装备怪兽由自己控制
function c88610708.damcon(e)
	return e:GetHandler():GetEquipTarget():GetControler()==e:GetHandlerPlayer()
end
