--モルトシュラーク
-- 效果：
-- 自己场上的通常召唤的怪兽才能装备。
-- ①：装备怪兽不受特殊召唤的对方场上的怪兽发动的效果影响。
-- ②：装备怪兽和特殊召唤的对方怪兽进行战斗的伤害计算时发动。那只对方怪兽的攻击力·守备力只在那次伤害计算时下降装备怪兽的原本攻击力数值。
function c12760674.initial_effect(c)
	-- 自己场上的通常召唤的怪兽才能装备。
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
-- 判定装备对象是否是由这张卡的控制者控制且通过通常召唤出场的怪兽，作为这张装备卡的装备限制条件。
function c12760674.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 筛选条件：怪兽需表侧表示且为通常召唤的怪兽，用于装备对象的选择。
function c12760674.filter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 装备魔法发动时的目标处理：校验选择的目标是自己场上表侧通常召唤怪兽；检查是否存在合法对象；提示并让玩家选择1只装备对象，同时登记装备操作信息。
function c12760674.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12760674.filter(chkc) end
	-- 发动合法性判定：自己场上是否存在至少1只表侧表示且通常召唤的怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c12760674.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择装备对象的提示信息“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只表侧通常召唤怪兽作为这张装备卡的装备对象（取对象）。
	Duel.SelectTarget(tp,c12760674.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记本次连锁的操作信息：类别为装备，对象为这张装备魔法卡自身，数量为1，用于效果处理内容的宣告。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若装备卡和目标怪兽仍与效果相关联，且目标怪兽表侧表示，则将这张装备卡装备给目标怪兽。
function c12760674.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的目标怪兽（装备对象）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备：将这张装备魔法卡作为装备卡装备到目标怪兽身上。
		Duel.Equip(tp,c,tc)
	end
end
-- 免疫效果的条件：只免疫对方玩家发动的、在怪兽区域发动的、且效果发动手是特殊召唤怪兽的效果，即特殊召唤的对方场上的怪兽发动的效果。
function c12760674.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:GetActivateLocation()==LOCATION_MZONE
		and te:IsActivated() and te:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- ②效果发动条件：装备怪兽作为攻击怪兽或攻击对象参与战斗，且其战斗对象是表侧表示的特殊召唤的对方怪兽。
function c12760674.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 若装备怪兽既不是攻击怪兽也不是攻击对象，则不满足②效果的发动条件。
	if ec~=Duel.GetAttacker() and ec~=Duel.GetAttackTarget() then return false end
	local tc=ec:GetBattleTarget()
	return tc and tc:IsFaceup() and tc:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果处理：将与该装备怪兽战斗的对方怪兽的攻击力·守备力下降装备怪兽原本攻击力的数值，仅限那次伤害计算。
function c12760674.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	local tc=ec:GetBattleTarget()
	if ec and tc and ec:IsFaceup() and tc:IsFaceup() then
		local val=math.max(ec:GetBaseAttack(),0)
		-- 那只对方怪兽的攻击力·守备力只在那次伤害计算时下降装备怪兽的原本攻击力数值。
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
