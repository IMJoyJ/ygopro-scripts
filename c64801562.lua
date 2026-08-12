--明鏡止水の心
-- 效果：
-- 装备这张卡的怪兽攻击力1300以上的场合这张卡破坏。这张卡装备的怪兽，不会被战斗和以那只怪兽为对象的卡的效果破坏。（仍然计算伤害）
function c64801562.initial_effect(c)
	-- （作为装备魔法卡的发动）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c64801562.target)
	e1:SetOperation(c64801562.operation)
	c:RegisterEffect(e1)
	-- 这张卡装备的怪兽，不会被战斗...破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 不会被...以那只怪兽为对象的卡的效果破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(c64801562.indval)
	c:RegisterEffect(e3)
	-- （装备限制）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 装备这张卡的怪兽攻击力1300以上的场合这张卡破坏
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_SELF_DESTROY)
	e5:SetCondition(c64801562.descon)
	c:RegisterEffect(e5)
	-- 装备这张卡的怪兽攻击力1300以上的场合这张卡破坏
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EVENT_ADJUST)
	e6:SetOperation(c64801562.descheck)
	c:RegisterEffect(e6)
end
-- 魔法卡发动时的对象选择与效果处理准备
function c64801562.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上一只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 魔法卡发动后的效果处理（将这张卡装备给目标怪兽）
function c64801562.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判定破坏该怪兽的效果是否为“以那只怪兽为对象的效果”
function c64801562.indval(e,re,rp)
	local tc=e:GetHandler():GetEquipTarget()
	local rc=re:GetHandler()
	-- 检查该效果是否取对象，且对象中是否包含该装备怪兽
	return (re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):IsContains(tc))
		or (re:IsHasType(EFFECT_TYPE_CONTINUOUS) and rc:IsHasCardTarget(tc))
end
-- 检查装备怪兽的攻击力是否在1300以上，作为自我破坏的条件
function c64801562.descon(e)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and tc:GetAttack()>=1300
end
-- 在伤害步骤中进行攻击力检测，若在1300以上则执行自我破坏
function c64801562.descheck(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	if ph>=PHASE_DAMAGE and ph<=PHASE_DAMAGE_CAL then
		local c=e:GetHandler()
		local tc=c:GetEquipTarget()
		if tc and tc:GetAttack()>=1300 then
			-- 因效果将这张卡破坏
			Duel.Destroy(c,REASON_EFFECT)
		end
	end
end
