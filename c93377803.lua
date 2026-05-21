--孤毒の剣
-- 效果：
-- 自己场上的怪兽才能装备。
-- ①：「孤毒之剑」在自己场上只能有1张表侧表示存在。
-- ②：装备怪兽的原本的攻击力·守备力只在和对方怪兽进行战斗的伤害计算时变成2倍。
-- ③：自己场上有装备怪兽以外的怪兽存在的场合这张卡送去墓地。
function c93377803.initial_effect(c)
	-- 开启全局标记以支持不入连锁的自我送墓效果（EFFECT_SELF_TOGRAVE）。
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	c:SetUniqueOnField(1,0,93377803)
	-- 自己场上的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c93377803.target)
	e1:SetOperation(c93377803.operation)
	c:RegisterEffect(e1)
	-- 自己场上的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c93377803.eqlimit)
	c:RegisterEffect(e2)
	-- ③：自己场上有装备怪兽以外的怪兽存在的场合这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_SELF_TOGRAVE)
	e3:SetCondition(c93377803.sdcon)
	c:RegisterEffect(e3)
	-- ②：装备怪兽的原本的攻击力·守备力只在和对方怪兽进行战斗的伤害计算时变成2倍。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_SET_BASE_ATTACK)
	e4:SetCondition(c93377803.adcon)
	e4:SetValue(c93377803.atkval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_BASE_DEFENSE)
	e5:SetValue(c93377803.defval)
	c:RegisterEffect(e5)
end
-- 装备限制：只能装备给自身控制者（自己）场上的怪兽。
function c93377803.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer())
end
-- 装备魔法卡发动时的目标选择与合法性检查。
function c93377803.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在可以装备的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 在界面上提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上一只表侧表示怪兽作为装备对象并设为效果目标。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示该效果包含装备卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的实际装备处理。
function c93377803.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 将这张卡作为装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断是否满足“自己场上有装备怪兽以外的怪兽存在”的送墓条件。
function c93377803.sdcon(e)
	local tc=e:GetHandler():GetEquipTarget()
	-- 检查自己场上是否存在除装备怪兽以外的其他怪兽。
	return tc and Duel.IsExistingMatchingCard(nil,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,tc)
end
-- 判断是否处于装备怪兽与对方怪兽进行战斗的伤害计算时。
function c93377803.adcon(e)
	-- 如果当前阶段不是伤害计算时，则不满足条件。
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
	local eqc=e:GetHandler():GetEquipTarget()
	-- 获取当前进行战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前进行战斗的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	return d and (a==eqc or d==eqc)
end
-- 计算并返回装备怪兽原本攻击力的2倍数值。
function c93377803.atkval(e,c)
	return c:GetBaseAttack()*2
end
-- 计算并返回装备怪兽原本守备力的2倍数值。
function c93377803.defval(e,c)
	return c:GetBaseDefense()*2
end
