--魔弾－クロス・ドミネーター
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「魔弹」怪兽存在的场合，以场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力·守备力变成0，效果无效化。
function c93356623.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「魔弹」怪兽存在的场合，以场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力·守备力变成0，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,93356623+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c93356623.condition)
	e1:SetTarget(c93356623.target)
	e1:SetOperation(c93356623.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「魔弹」怪兽
function c93356623.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x108)
end
-- 发动条件：自己场上有「魔弹」怪兽存在，且非伤害计算后
function c93356623.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「魔弹」怪兽
	return Duel.IsExistingMatchingCard(c93356623.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查当前是否不处于伤害计算后（限制伤害步骤的发动时机）
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤条件：场上表侧表示，且攻击力大于0、守备力大于0或效果未被无效的怪兽
function c93356623.filter(c)
	-- 检查卡片是否为表侧表示，且其攻击力或守备力大于0，或者其效果可以被无效
	return c:IsFaceup() and (c:GetAttack()>0 or c:GetDefense()>0 or aux.NegateMonsterFilter(c))
end
-- 效果发动时的目标选择与合法性检查
function c93356623.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c93356623.filter(chkc) end
	-- 在发动阶段（chk==0）检查场上是否存在至少1只符合条件的表侧表示怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c93356623.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息：请选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1只符合条件的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c93356623.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：使目标怪兽的攻击力·守备力变成0，并将其效果无效化
function c93356623.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果处理的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 直到回合结束时，那只怪兽的攻击力·守备力变成0
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_SET_ATTACK_FINAL)
		e0:SetValue(0)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e0)
		local e1=e0:Clone()
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e1)
		-- 使与目标怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
