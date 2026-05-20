--Emミラー・コンダクター
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，以场上1只特殊召唤的表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时变成和那个攻击力与守备力之内较低方的数值相同。
-- 【怪兽效果】
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时交换。那之后，自己受到500伤害。这个效果在对方回合也能发动。
function c71578874.initial_effect(c)
	-- 启用灵摆怪兽属性（注册灵摆召唤及灵摆卡的发动等规则）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以场上1只特殊召唤的表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时变成和那个攻击力与守备力之内较低方的数值相同。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c71578874.adtg)
	e2:SetOperation(c71578874.adop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时交换。那之后，自己受到500伤害。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetCountLimit(1)
	-- 设置效果发动条件为不在伤害计算后（允许在伤害步骤的伤害计算前发动）
	e3:SetCondition(aux.dscon)
	e3:SetTarget(c71578874.swtg)
	e3:SetOperation(c71578874.swop)
	c:RegisterEffect(e3)
end
-- 过滤场上特殊召唤的、表侧表示的、且攻击力与守备力不相等的怪兽
function c71578874.filter(c)
	return c:IsFaceup() and not c:IsAttack(c:GetDefense()) and c:IsDefenseAbove(0)
		and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 灵摆效果的发动准备（检查并选择符合条件的怪兽作为对象）
function c71578874.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c71578874.filter(chkc) end
	-- 检查场上是否存在至少1只符合条件的特殊召唤的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c71578874.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只符合条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c71578874.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 灵摆效果的执行（将对象怪兽的攻击力·守备力直到回合结束时变成较低方的数值）
function c71578874.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local val=math.min(tc:GetAttack(),tc:GetDefense())
		-- 那只怪兽的攻击力·守备力直到回合结束时变成和那个攻击力与守备力之内较低方的数值相同。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(val)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
	end
end
-- 过滤场上表侧表示且守备力大于等于0的怪兽
function c71578874.swfilter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 怪兽效果的发动准备（检查并选择表侧表示怪兽作为对象，并注册伤害操作信息）
function c71578874.swtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c71578874.swfilter(chkc) end
	-- 检查场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c71578874.swfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只表侧表示的怪兽作为效果的对象
	Duel.SelectTarget(tp,c71578874.swfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为对自身造成500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,500)
end
-- 怪兽效果的执行（交换对象怪兽的攻守数值，之后对自己造成500点伤害）
function c71578874.swop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 那只怪兽的攻击力·守备力直到回合结束时交换。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		-- 中断当前效果处理，使后续的伤害处理与攻守交换不视为同时进行
		Duel.BreakEffect()
		-- 因效果对自身造成500点伤害
		Duel.Damage(tp,500,REASON_EFFECT)
	end
end
