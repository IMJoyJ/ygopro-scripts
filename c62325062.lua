--粘着落とし穴
-- 效果：
-- 对方对怪兽的召唤·反转召唤·特殊召唤成功时才能发动。那怪兽只要在场上表侧表示存在，原本攻击力变成一半数值。
function c62325062.initial_effect(c)
	-- 对方对怪兽的召唤·反转召唤·特殊召唤成功时才能发动。那怪兽只要在场上表侧表示存在，原本攻击力变成一半数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c62325062.target)
	e1:SetOperation(c62325062.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤出对方召唤·反转召唤·特殊召唤成功的表侧表示怪兽
function c62325062.filter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(1-tp)
end
-- 检查是否存在符合条件的怪兽，并将召唤成功的怪兽群设为效果处理的对象
function c62325062.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c62325062.filter,1,nil,tp) end
	-- 将召唤成功的怪兽群设为效果处理的对象
	Duel.SetTargetCard(eg)
end
-- 过滤出在场上表侧表示存在、由对方召唤且仍与本效果有关联的怪兽
function c62325062.filter2(c,e,tp)
	return c:IsFaceup() and c:IsSummonPlayer(1-tp) and c:IsRelateToEffect(e)
end
-- 效果处理，筛选出符合条件的怪兽，并将其原本攻击力变成一半数值
function c62325062.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c62325062.filter2,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		local atk=math.ceil(tc:GetBaseAttack()/2)
		-- 那怪兽只要在场上表侧表示存在，原本攻击力变成一半数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
