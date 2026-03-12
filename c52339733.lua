--竜胆ブルーム
-- 效果：
-- ①：这张卡在怪兽区域存在，自己怪兽和对方怪兽进行战斗的伤害计算时发动。直到伤害步骤结束时，进行战斗的各自怪兽的攻击力变成和各自守备力相同数值。
function c52339733.initial_effect(c)
	-- 效果原文内容：①：这张卡在怪兽区域存在，自己怪兽和对方怪兽进行战斗的伤害计算时发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c52339733.atkcon)
	e1:SetOperation(c52339733.atkop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断是否满足发动条件，即攻击怪兽与防守怪兽不同控制者且至少一方守备力大于0
function c52339733.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 规则层面作用：获取本次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	return d and a:GetControler()~=d:GetControler()
		and (a:IsDefenseAbove(0) or d:IsDefenseAbove(0))
end
-- 规则层面作用：执行效果处理，设置攻击怪兽和防守怪兽的攻击力为各自守备力
function c52339733.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 规则层面作用：获取本次战斗的防守怪兽
	local d=Duel.GetAttackTarget()
	if a:IsFaceup() and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle() then
		-- 效果原文内容：直到伤害步骤结束时，进行战斗的各自怪兽的攻击力变成和各自守备力相同数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		if a:IsDefenseAbove(0) then
			e1:SetValue(a:GetDefense())
			a:RegisterEffect(e1)
		end
		if d:IsDefenseAbove(0) then
			local e2=e1:Clone()
			e2:SetValue(d:GetDefense())
			d:RegisterEffect(e2)
		end
	end
end
