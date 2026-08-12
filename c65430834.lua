--ジュラシック・インパクト
-- 效果：
-- ①：自己场上有恐龙族怪兽2只以上存在，自己基本分比对方少的场合才能发动。场上的怪兽全部破坏，自己受到破坏的怪兽数量×1000伤害。那之后，给与对方为和自己受到的伤害相同数值的伤害。这张卡的发动后，直到下个回合的结束时双方不能把怪兽召唤·特殊召唤。
function c65430834.initial_effect(c)
	-- ①：自己场上有恐龙族怪兽2只以上存在，自己基本分比对方少的场合才能发动。场上的怪兽全部破坏，自己受到破坏的怪兽数量×1000伤害。那之后，给与对方为和自己受到的伤害相同数值的伤害。这张卡的发动后，直到下个回合的结束时双方不能把怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c65430834.condition)
	e1:SetTarget(c65430834.target)
	e1:SetOperation(c65430834.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查自己场上的恐龙族怪兽数量以及双方基本分
function c65430834.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在2只以上的恐龙族怪兽，且自己的基本分低于对方
	return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_MZONE,0,2,nil,RACE_DINOSAUR) and Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 效果的目标与操作信息设置
function c65430834.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时，场上必须存在至少1只怪兽
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0 end
	-- 获取场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	-- 设置破坏的操作信息，包含场上的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置伤害的操作信息，数值为场上怪兽数量×1000
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,g:GetCount()*1000)
end
-- 效果处理：破坏怪兽、造成伤害，并适用召唤限制
function c65430834.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	-- 破坏场上的所有怪兽，并获取实际被破坏的怪兽数量
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		-- 自己受到被破坏怪兽数量×1000的伤害，并获取实际受到的伤害数值
		local val=Duel.Damage(tp,ct*1000,REASON_EFFECT)
		-- 若自己实际受到了伤害且基本分大于0，则继续处理给与对方伤害的效果
		if val>0 and Duel.GetLP(tp)>0 then
			-- 中断当前效果处理，使后续伤害处理与前面的破坏、自己受伤害不视为同时处理
			Duel.BreakEffect()
			-- 给与对方与自己受到的伤害相同数值的伤害
			Duel.Damage(1-tp,val,REASON_EFFECT)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下个回合的结束时双方不能把怪兽召唤·特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetTargetRange(1,1)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 注册限制双方召唤的全局效果，持续到下个回合结束
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		-- 注册限制双方特殊召唤的全局效果，持续到下个回合结束
		Duel.RegisterEffect(e2,tp)
	end
end
