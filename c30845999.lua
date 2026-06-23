--起動する機殻
-- 效果：
-- ①：场上的通常召唤的「机壳」怪兽直到回合结束时攻击力上升300，效果无效化，不受这张卡以外的魔法·陷阱卡的效果影响。
function c30845999.initial_effect(c)
	-- 创建效果e1，设置为魔法卡发动效果，提示在伤害步骤时点发动，允许在伤害步骤发动，设置为自由连锁，条件为aux.dscon，目标函数为c30845999.target，发动函数为c30845999.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置效果发动条件为aux.dscon，即只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c30845999.target)
	e1:SetOperation(c30845999.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，返回场上正面表示的、卡名含机壳字段且为通常召唤的怪兽
function c30845999.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xaa) and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 目标函数，检查场上是否存在满足过滤条件的怪兽
function c30845999.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c30845999.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 发动函数，获取场上满足条件的怪兽组，对每个怪兽施加效果
function c30845999.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上满足过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c30845999.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 给目标怪兽增加300攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(300)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 使目标怪兽效果无效化（持续到回合结束）
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		-- 使目标怪兽不受除自身外的魔法·陷阱卡效果影响
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCode(EFFECT_IMMUNE_EFFECT)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e4:SetValue(c30845999.efilter)
		tc:RegisterEffect(e4)
		tc=g:GetNext()
	end
end
-- 效果免疫函数，返回true当效果为魔法或陷阱卡且所有者不是自身
function c30845999.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwner()~=e:GetOwner()
end
