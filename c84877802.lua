--最強の盾
-- 效果：
-- 战士族怪兽才能装备。
-- ①：装备怪兽的表示形式的以下效果适用。
-- ●攻击表示：装备怪兽的攻击力上升那个原本守备力数值。
-- ●守备表示：装备怪兽的守备力上升那个原本攻击力数值。
function c84877802.initial_effect(c)
	-- 战士族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c84877802.target)
	e1:SetOperation(c84877802.operation)
	c:RegisterEffect(e1)
	-- ●攻击表示：装备怪兽的攻击力上升那个原本守备力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c84877802.atkval)
	c:RegisterEffect(e2)
	-- ●守备表示：装备怪兽的守备力上升那个原本攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(c84877802.defval)
	c:RegisterEffect(e3)
	-- 战士族怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c84877802.equiplimit)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给战士族怪兽
function c84877802.equiplimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 过滤场上表侧表示的战士族怪兽
function c84877802.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 装备魔法卡发动时的效果靶向（选择目标）与效果处理
function c84877802.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c84877802.filter(chkc) end
	-- 在发动阶段，检查场上是否存在可以装备的合法目标
	if chk==0 then return Duel.IsExistingTarget(c84877802.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的战士族怪兽作为装备对象
	Duel.SelectTarget(tp,c84877802.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁运营信息，表明此卡将作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的效果处理，将此卡装备给目标怪兽
function c84877802.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算攻击力上升值：若装备怪兽为攻击表示，则上升其原本守备力数值
function c84877802.atkval(e,c)
	if c:IsDefensePos() then return 0 else return c:GetBaseDefense() end
end
-- 计算守备力上升值：若装备怪兽为守备表示，则上升其原本攻击力数值
function c84877802.defval(e,c)
	if c:IsAttackPos() then return 0 else return c:GetBaseAttack() end
end
