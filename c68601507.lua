--武神器－ハバキリ
-- 效果：
-- ①：自己的兽战士族「武神」怪兽和对方怪兽进行战斗的伤害计算时把这张卡从手卡送去墓地才能发动。那只进行战斗的自己怪兽的攻击力只在那次伤害计算时变成原本攻击力的2倍。
function c68601507.initial_effect(c)
	-- ①：自己的兽战士族「武神」怪兽和对方怪兽进行战斗的伤害计算时把这张卡从手卡送去墓地才能发动。那只进行战斗的自己怪兽的攻击力只在那次伤害计算时变成原本攻击力的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68601507,0))  --"攻击变化"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c68601507.atkcon)
	e1:SetCost(c68601507.atkcost)
	e1:SetOperation(c68601507.atkop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：是否为自己的兽战士族「武神」怪兽与对方怪兽进行战斗的伤害计算时，并记录该己方怪兽
function c68601507.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的被攻击怪兽
	local c=Duel.GetAttackTarget()
	if not c then return false end
	-- 如果被攻击怪兽是对方的，则将目标怪兽切换为攻击方的己方怪兽
	if c:IsControler(1-tp) then c=Duel.GetAttacker() end
	e:SetLabelObject(c)
	return c and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR) and c:IsRelateToBattle()
end
-- 检查并执行发动代价：把这张卡从手卡送去墓地
function c68601507.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 执行效果：使进行战斗的自己怪兽的攻击力只在那次伤害计算时变成原本攻击力的2倍
function c68601507.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	if c:IsFaceup() and c:IsRelateToBattle() then
		-- 那只进行战斗的自己怪兽的攻击力只在那次伤害计算时变成原本攻击力的2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(c:GetBaseAttack()*2)
		c:RegisterEffect(e1)
	end
end
