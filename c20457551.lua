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
-- 定义装备对象限制函数：检查对象怪兽是否是「核成」系列（0x1d）。
function c20457551.eqlimit(e,c)
	return c:IsSetCard(0x1d)
end
-- 定义筛选函数：检查怪兽是否表侧表示且属于「核成」系列。
function c20457551.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d)
end
-- 定义效果目标函数：选择场上表侧表示的「核成」怪兽作为装备对象，并设置操作信息。
function c20457551.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c20457551.filter(chkc) end
	-- 检查双方场上是否存在可作为装备对象的「核成」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c20457551.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息：请选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方场上选择1只表侧表示的「核成」怪兽作为装备目标。
	Duel.SelectTarget(tp,c20457551.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：将此卡作为装备卡装备（CATEGORY_EQUIP）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 定义效果处理函数：将此卡装备给选择的怪兽。
function c20457551.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁选择的第一个目标（要装备的怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备动作：将此卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- 定义攻击力更新条件函数：仅在伤害计算时且装备怪兽存在战斗对象时生效。
function c20457551.atkcon(e)
	-- 检查当前阶段是否为伤害计算时（PHASE_DAMAGE_CAL）。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		and e:GetHandler():GetEquipTarget():GetBattleTarget()
end
-- 定义攻击力更新目标函数：指定与装备怪兽进行战斗的对方怪兽。
function c20457551.atktg(e,c)
	return c==e:GetHandler():GetEquipTarget():GetBattleTarget()
end
-- 定义攻击力更新数值函数：返回装备怪兽等级×-100（攻击力下降数值）。
function c20457551.atkval(e,c)
	return e:GetHandler():GetEquipTarget():GetLevel()*-100
end
-- 定义代替破坏效果的目标函数：在结束阶段装备怪兽被破坏时代替破坏。
function c20457551.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前是否为结束阶段且此卡未被预定破坏。
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_END and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED)
		and not e:GetHandler():GetEquipTarget():IsReason(REASON_REPLACE) end
	-- 询问玩家是否发动代替破坏效果（将此卡送去墓地代替装备怪兽破坏）。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 将此装备卡送去墓地，作为装备怪兽被破坏的代替。
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
		return true
	else return false end
end
