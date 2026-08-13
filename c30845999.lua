--起動する機殻
-- 效果：
-- ①：场上的通常召唤的「机壳」怪兽直到回合结束时攻击力上升300，效果无效化，不受这张卡以外的魔法·陷阱卡的效果影响。
function c30845999.initial_effect(c)
	-- ①：场上的通常召唤的「机壳」怪兽直到回合结束时攻击力上升300，效果无效化，不受这张卡以外的魔法·陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置发动条件为当前不在伤害步骤或尚未进行伤害计算，使该卡可在伤害步骤伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c30845999.target)
	e1:SetOperation(c30845999.activate)
	c:RegisterEffect(e1)
end
-- 定义效果适用对象的筛选条件：场上表侧表示、属于「机壳」系列、且通过通常召唤出场的怪兽。
function c30845999.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xaa) and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 效果发动时的条件检测：在发动合法性检查时确认场上是否存在至少1只满足筛选条件的「机壳」通常召唤怪兽（本效果不取对象）。
function c30845999.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0（发动合法性检查）时，返回场上是否存在至少1只满足c30845999.filter条件的怪兽，作为能否发动的依据。
	if chk==0 then return Duel.IsExistingMatchingCard(c30845999.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果处理：选取场上所有满足条件的「机壳」通常召唤怪兽，对每只分别使其相关的连锁无效化、攻击力上升300、效果无效化、并免疫这张卡以外的魔法·陷阱卡效果，这些状态持续到回合结束时。
function c30845999.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方场上所有满足c30845999.filter条件的表侧通常召唤「机壳」怪兽集合。
	local g=Duel.GetMatchingGroup(c30845999.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使该怪兽相关的连锁无效化，并设定在怪兽变里侧表示时重置该无效状态（对应“效果无效化”的连锁层面处理）。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 直到回合结束时攻击力上升300
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(300)
		tc:RegisterEffect(e1)
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
		-- 不受这张卡以外的魔法·陷阱卡的效果影响
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
-- 定义免疫效果的过滤条件：效果类型为魔法·陷阱卡，且效果持有者不是「起动的机壳」自身，即只免疫“这张卡以外的魔法·陷阱卡”的效果。
function c30845999.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwner()~=e:GetOwner()
end
