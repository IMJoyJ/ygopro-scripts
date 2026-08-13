--ワーム・ウォーロード
-- 效果：
-- 这张卡不能特殊召唤。这张卡战斗破坏的效果怪兽的效果无效化。这张卡战斗破坏对方怪兽的场合，只有1次可以继续攻击。
function c35638627.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏的效果怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetOperation(c35638627.disop)
	c:RegisterEffect(e2)
	-- 这张卡战斗破坏对方怪兽的场合，只有1次可以继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35638627,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c35638627.atcon)
	e3:SetOperation(c35638627.atop)
	c:RegisterEffect(e3)
end
-- 对本次战斗被破坏的效果怪兽施加效果无效化和效果文本无效化，并设置重置事件使这些无效化状态在怪兽离场等时解除。
function c35638627.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得攻击目标怪兽，用于确定被本卡战斗破坏的怪兽。
	local tc=Duel.GetAttackTarget()
	local c=e:GetHandler()
	-- 若本卡就是攻击目标（即本卡作为被攻击方），则将该变量改为攻击者，以锁定与本卡战斗并被破坏的怪兽。
	if c==tc then tc=Duel.GetAttacker() end
	if tc and tc:IsType(TYPE_EFFECT) and tc:IsStatus(STATUS_BATTLE_DESTROYED) then
		-- 这张卡战斗破坏的效果怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x17a0000)
		tc:RegisterEffect(e1)
		-- 这张卡战斗破坏的效果怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x17a0000)
		tc:RegisterEffect(e2)
	end
end
-- 作为连续攻击效果的发动条件，判断是否满足本卡与对方怪兽战斗并将其破坏，以及本卡是否还能进行连续攻击。
function c35638627.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回条件判断结果：本卡与对方怪兽战斗并破坏了对方怪兽，且本卡仍可进行连续攻击。
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
end
-- 作为效果处理操作，在条件成立时执行连续攻击，让本卡获得追加一次攻击的能力。
function c35638627.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使本卡可以立刻追加一次攻击，即进行一次额外的攻击。
	Duel.ChainAttack()
end
