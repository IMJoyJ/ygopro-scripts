--反転世界
-- 效果：
-- 场上表侧表示存在的全部效果怪兽的攻击力·守备力交换。
function c79161790.initial_effect(c)
	-- 场上表侧表示存在的全部效果怪兽的攻击力·守备力交换。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动的条件为伤害步骤中伤害计算前
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c79161790.target)
	e1:SetOperation(c79161790.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示、是效果怪兽、且守备力在0以上的怪兽
function c79161790.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsDefenseAbove(0)
end
-- 效果发动的目标选择与合法性检查函数
function c79161790.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c79161790.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果处理的核心逻辑，获取所有符合条件的怪兽并逐一交换其攻击力和守备力
function c79161790.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足过滤条件的怪兽
	local sg=Duel.GetMatchingGroup(c79161790.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local c=e:GetHandler()
	local tc=sg:GetFirst()
	while tc do
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 攻击力·守备力交换
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(def)
		tc:RegisterEffect(e1)
		-- 攻击力·守备力交换
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		tc=sg:GetNext()
	end
end
