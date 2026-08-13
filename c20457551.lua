--鋼核収納
-- 效果：
-- 名字带有「核成」的怪兽才能装备。和装备怪兽进行战斗的对方怪兽的攻击力只在那次伤害计算时下降装备怪兽的等级×100的数值。装备怪兽在结束阶段时被破坏的场合，可以作为代替把这张卡送去墓地。
function c20457551.initial_effect(c)
	-- 名字带有「核成」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c20457551.target)
	e1:SetOperation(c20457551.operation)
	c:RegisterEffect(e1)
	-- 名字带有「核成」的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c20457551.eqlimit)
	c:RegisterEffect(e2)
	-- 和装备怪兽进行战斗的对方怪兽的攻击力只在那次伤害计算时下降装备怪兽的等级×100的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c20457551.atkcon)
	e3:SetTarget(c20457551.atktg)
	e3:SetValue(c20457551.atkval)
	c:RegisterEffect(e3)
	-- 装备怪兽在结束阶段时被破坏的场合，可以作为代替把这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(c20457551.desreptg)
	c:RegisterEffect(e4)
end
-- 装备限制判定：只有卡名带有「核成」字段的怪兽才能成为此卡的装备对象。
function c20457551.eqlimit(e,c)
	return c:IsSetCard(0x1d)
end
-- 筛选表侧表示且卡名带有「核成」字段的怪兽，用于发动时选择装备对象。
function c20457551.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d)
end
-- 装备魔法的发动处理：检测场上是否存在可装备的核成怪兽，让玩家选择1只并登记为效果对象，同时设置操作信息为装备。
function c20457551.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c20457551.filter(chkc) end
	-- 发动条件检查：场上是否存在至少1只满足filter条件的表侧表示核成怪兽。
	if chk==0 then return Duel.IsExistingTarget(c20457551.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择装备怪兽的提示文字“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方怪兽区域选择1只满足filter条件的核成怪兽作为装备对象，并设为效果的对象。
	Duel.SelectTarget(tp,c20457551.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记本次效果的操作信息为CATEGORY_EQUIP，对象为此卡本身，用于后续连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡和目标怪兽都仍与效果关联且目标仍表侧表示，则将此卡装备给目标怪兽。
function c20457551.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- 攻击力变化效果的适用条件：当前为伤害计算时，且装备怪兽存在战斗对象。
function c20457551.atkcon(e)
	-- 判断当前是否为伤害计算时。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		and e:GetHandler():GetEquipTarget():GetBattleTarget()
end
-- 攻击力变化的目标判定：只有与装备怪兽进行战斗的对方怪兽才适用此攻击力下降。
function c20457551.atktg(e,c)
	return c==e:GetHandler():GetEquipTarget():GetBattleTarget()
end
-- 计算攻击力下降数值为装备怪兽的等级×100，以负值形式返回（即下降攻击力）。
function c20457551.atkval(e,c)
	return e:GetHandler():GetEquipTarget():GetLevel()*-100
end
-- 代替破坏效果的触发条件：装备怪兽在结束阶段将要被破坏时，若此卡未被预定破坏且装备怪兽的破坏原因不是代替，则可发动代替破坏。
function c20457551.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前是结束阶段、此卡未被预定破坏（防止重复发动）且装备怪兽的破坏不是由代替原因引起的。
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_END and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED)
		and not e:GetHandler():GetEquipTarget():IsReason(REASON_REPLACE) end
	-- 询问玩家是否将这张卡送去墓地以代替装备怪兽被破坏。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 将此卡送去墓地，以代替装备怪兽的破坏。
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
		return true
	else return false end
end
