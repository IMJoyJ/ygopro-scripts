--右手に盾を左手に剣を
-- 效果：
-- 这张卡的发动时场上表侧表示存在的全部怪兽的原本攻击力与原本守备力直到结束阶段时交换。
function c52097679.initial_effect(c)
	-- 对应效果原文：“这张卡的发动时场上表侧表示存在的全部怪兽的原本攻击力与原本守备力直到结束阶段时交换。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52097679.target)
	e1:SetOperation(c52097679.activate)
	c:RegisterEffect(e1)
end
-- 筛选场上表侧表示且守备力不低于0的怪兽（即所有表侧表示怪兽），作为效果适用对象。
function c52097679.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 发动条件判定：确认此效果为魔法卡的发动，且场上存在至少1只符合条件的表侧表示怪兽。
function c52097679.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 检查双方主要怪兽区是否存在至少1只表侧表示且守备力不低于0的怪兽。
		and Duel.IsExistingMatchingCard(c52097679.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方主要怪兽区所有表侧表示且守备力不低于0的怪兽，组成集合。
	local g=Duel.GetMatchingGroup(c52097679.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将上述怪兽集合设置为当前连锁的对象（广义对象），用于记录效果涉及的所有怪兽。
	Duel.SetTargetCard(g)
end
-- 效果处理时的筛选函数：保留仍为表侧表示、与效果仍有联系且不免疫该效果的怪兽。
function c52097679.efilter(c,e)
	return c52097679.filter(c) and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end
-- 效果处理：取得符合条件的全部怪兽，将每只怪兽的原本攻击力与原本守备力交换，持续到结束阶段。
function c52097679.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新取得场上符合条件的怪兽集合（排除已离场或免疫的怪兽）。
	local sg=Duel.GetMatchingGroup(c52097679.efilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	local c=e:GetHandler()
	local tc=sg:GetFirst()
	while tc do
		local batk=tc:GetBaseAttack()
		local bdef=tc:GetBaseDefense()
		-- 对应效果原文中交换原本攻击力的部分：原本攻击力与原本守备力直到结束阶段时交换（此处为将原本攻击力改为原本守备力）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(bdef)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
		e2:SetValue(batk)
		tc:RegisterEffect(e2)
		tc=sg:GetNext()
	end
end
