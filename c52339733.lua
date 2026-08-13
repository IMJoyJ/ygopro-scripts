--竜胆ブルーム
-- 效果：
-- ①：这张卡在怪兽区域存在，自己怪兽和对方怪兽进行战斗的伤害计算时发动。直到伤害步骤结束时，进行战斗的各自怪兽的攻击力变成和各自守备力相同数值。
function c52339733.initial_effect(c)
	-- ①：这张卡在怪兽区域存在，自己怪兽和对方怪兽进行战斗的伤害计算时发动。直到伤害步骤结束时，进行战斗的各自怪兽的攻击力变成和各自守备力相同数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c52339733.atkcon)
	e1:SetOperation(c52339733.atkop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：获取本次战斗的攻击怪兽和被攻击怪兽，要求存在攻击目标且双方控制者不同（即己方怪兽与对方怪兽进行战斗），并且至少一方怪兽的守备力不低于0。
function c52339733.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽（攻击目标；直接攻击时可能为空）。
	local d=Duel.GetAttackTarget()
	return d and a:GetControler()~=d:GetControler()
		and (a:IsDefenseAbove(0) or d:IsDefenseAbove(0))
end
-- 效果处理：若攻击怪兽和被攻击怪兽都表侧表示且仍与本次战斗相关联，则创建一个持续到伤害计算阶段结束的临时效果，将攻击力变为各自守备力；对攻击方和防守方分别适用。
function c52339733.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽（攻击目标）。
	local d=Duel.GetAttackTarget()
	if a:IsFaceup() and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle() then
		-- 直到伤害步骤结束时，进行战斗的攻击方怪兽的攻击力变成和其守备力相同数值。
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
