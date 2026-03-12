--右手に盾を左手に剣を
-- 效果：
-- 这张卡的发动时场上表侧表示存在的全部怪兽的原本攻击力与原本守备力直到结束阶段时交换。
function c52097679.initial_effect(c)
	-- 效果原文内容：这张卡的发动时场上表侧表示存在的全部怪兽的原本攻击力与原本守备力直到结束阶段时交换。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52097679.target)
	e1:SetOperation(c52097679.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：表侧表示且守备力大于等于0的怪兽
function c52097679.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 判断是否可以发动此效果：确认该效果为发动类型且场上存在至少1只满足条件的怪兽
function c52097679.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 判断是否可以发动此效果：确认场上存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c52097679.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取满足条件的怪兽数组
	local g=Duel.GetMatchingGroup(c52097679.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将目标怪兽设置为上述获取的怪兽数组
	Duel.SetTargetCard(g)
end
-- 检索满足条件的卡片组：表侧表示且与效果相关联且未免疫该效果的怪兽
function c52097679.efilter(c,e)
	return c52097679.filter(c) and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end
-- 处理效果发动时的执行逻辑：获取满足条件的怪兽并交换其原本攻击力与守备力
function c52097679.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与效果相关联且未免疫该效果的怪兽数组
	local sg=Duel.GetMatchingGroup(c52097679.efilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	local c=e:GetHandler()
	local tc=sg:GetFirst()
	while tc do
		local batk=tc:GetBaseAttack()
		local bdef=tc:GetBaseDefense()
		-- 为怪兽临时改变其原本攻击力为原本守备力
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
