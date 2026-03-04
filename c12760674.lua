--モルトシュラーク
-- 效果：
-- 自己场上的通常召唤的怪兽才能装备。
-- ①：装备怪兽不受特殊召唤的对方场上的怪兽发动的效果影响。
-- ②：装备怪兽和特殊召唤的对方怪兽进行战斗的伤害计算时发动。那只对方怪兽的攻击力·守备力只在那次伤害计算时下降装备怪兽的原本攻击力数值。
function c12760674.initial_effect(c)
	-- ①：装备怪兽不受特殊召唤的对方场上的怪兽发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c12760674.target)
	e1:SetOperation(c12760674.operation)
	c:RegisterEffect(e1)
	-- 自己场上的通常召唤的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c12760674.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽不受特殊召唤的对方场上的怪兽发动的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(c12760674.efilter)
	c:RegisterEffect(e3)
	-- ②：装备怪兽和特殊召唤的对方怪兽进行战斗的伤害计算时发动。那只对方怪兽的攻击力·守备力只在那次伤害计算时下降装备怪兽的原本攻击力数值。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c12760674.atkcon)
	e4:SetOperation(c12760674.atkop)
	c:RegisterEffect(e4)
end
-- 判断装备对象是否为己方通常召唤的怪兽
function c12760674.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 筛选己方场上正面表示的通常召唤怪兽
function c12760674.filter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 设置效果目标为己方场上正面表示的通常召唤怪兽
function c12760674.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12760674.filter(chkc) end
	-- 检查是否存在符合条件的装备目标
	if chk==0 then return Duel.IsExistingTarget(c12760674.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,c12760674.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果操作信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c12760674.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判断是否为对方在怪兽区发动的特殊召唤效果
function c12760674.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:GetActivateLocation()==LOCATION_MZONE
		and te:IsActivated() and te:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 判断伤害计算时是否满足效果发动条件
function c12760674.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 确认装备怪兽是否参与了此次战斗
	if ec~=Duel.GetAttacker() and ec~=Duel.GetAttackTarget() then return false end
	local tc=ec:GetBattleTarget()
	return tc and tc:IsFaceup() and tc:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 执行伤害计算时的攻击力·守备力调整效果
function c12760674.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	local tc=ec:GetBattleTarget()
	if ec and tc and ec:IsFaceup() and tc:IsFaceup() then
		local val=math.max(ec:GetBaseAttack(),0)
		-- 装备怪兽的原本攻击力在伤害计算时对对方怪兽造成下降效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
