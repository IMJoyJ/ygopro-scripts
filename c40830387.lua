--古代の機械掌
-- 效果：
-- 名字带有「古代的机械」的怪兽才能装备。和装备怪兽进行战斗的怪兽在那个伤害步骤结束时破坏。
function c40830387.initial_effect(c)
	-- 名字带有「古代的机械」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c40830387.target)
	e1:SetOperation(c40830387.operation)
	c:RegisterEffect(e1)
	-- 名字带有「古代的机械」的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c40830387.eqlimit)
	c:RegisterEffect(e2)
	-- 和装备怪兽进行战斗的怪兽在那个伤害步骤结束时破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40830387,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c40830387.descon)
	e3:SetTarget(c40830387.destg)
	e3:SetOperation(c40830387.desop)
	c:RegisterEffect(e3)
end
-- 装备限制判定：返回被选择对象是否为卡名带有「古代的机械」的怪兽，以此决定装备魔法能否装备给该怪兽。
function c40830387.eqlimit(e,c)
	return c:IsSetCard(0x7)
end
-- 筛选怪兽：判断怪兽是否为表侧表示且卡名带有「古代的机械」，用于选择装备对象。
function c40830387.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x7)
end
-- 装备魔法的发动时点处理：先检查是否存在符合条件的对象，再让玩家选择场上1只表侧表示的「古代的机械」怪兽，并设置装备操作信息。
function c40830387.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c40830387.filter(chkc) end
	-- 发动合法性检查：若处于检查阶段，确认场上是否存在至少1只表侧表示且名字带有「古代的机械」的怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c40830387.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让操作玩家从自己场上选择1只表侧表示且名字带有「古代的机械」的怪兽作为装备对象，并将其登记为本次连锁的对象。
	Duel.SelectTarget(tp,c40830387.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备魔法的处理信息：明确当前连锁将进行装备操作，处理对象为这张装备魔法卡本身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，确认装备魔法卡和选择的怪兽都仍与本次效果关联，且对象仍表侧表示，则执行装备。
function c40830387.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取出效果发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将该装备魔法卡作为装备卡装备到目标怪兽上。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 破坏效果的触发条件：在伤害步骤结束时，根据装备怪兽的战斗关系确定与之战斗的怪兽，作为潜在破坏对象。
function c40830387.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local dt=nil
	-- 如果装备怪兽是攻击怪兽，则将与此战斗的怪兽设为攻击目标。
	if ec==Duel.GetAttacker() then dt=Duel.GetAttackTarget()
	-- 否则，如果装备怪兽是攻击目标，则将与此战斗的怪兽设为攻击怪兽。
	elseif ec==Duel.GetAttackTarget() then dt=Duel.GetAttacker() end
	e:SetLabelObject(dt)
	return dt and dt:IsRelateToBattle()
end
-- 破坏效果的目标处理：由于是诱发必发效果，发动时无需额外选择，直接设置破坏对象为记录中的战斗怪兽。
function c40830387.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置破坏处理信息：目标为记录的战斗怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 破坏效果处理：若记录的战斗怪兽仍与本次战斗相关联，则将其破坏。
function c40830387.desop(e,tp,eg,ep,ev,re,r,rp)
	local dt=e:GetLabelObject()
	if dt:IsRelateToBattle() then
		-- 以效果原因将这只与装备怪兽进行战斗的怪兽破坏。
		Duel.Destroy(dt,REASON_EFFECT)
	end
end
