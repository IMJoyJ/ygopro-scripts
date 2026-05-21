--スピード・ウォリアー
-- 效果：
-- ①：这张卡的召唤成功的回合的战斗步骤才能发动。这张卡的攻击力直到战斗阶段结束时变成原本攻击力的2倍。
function c9365703.initial_effect(c)
	-- 这张卡的召唤成功的回合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c9365703.sumop)
	c:RegisterEffect(e1)
	-- ①：这张卡的召唤成功的回合的战斗步骤才能发动。这张卡的攻击力直到战斗阶段结束时变成原本攻击力的2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9365703,0))  --"攻击变化"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c9365703.dacon)
	e2:SetOperation(c9365703.daop)
	c:RegisterEffect(e2)
end
-- 在召唤成功时，给这张卡注册一个在回合结束时重置的标记，用于记录该卡是在本回合召唤成功的
function c9365703.sumop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(9365703,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否满足发动条件：当前为战斗步骤、不入连锁，且该卡具有本回合召唤成功的标记
function c9365703.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为战斗步骤，且当前连锁数是否为0
	return Duel.GetCurrentPhase()==PHASE_BATTLE_STEP and Duel.GetCurrentChain()==0
		and e:GetHandler():GetFlagEffect(9365703)~=0
end
-- 效果处理：使该卡的攻击力直到战斗阶段结束时变成原本攻击力的2倍
function c9365703.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的攻击力直到战斗阶段结束时变成原本攻击力的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(c:GetBaseAttack()*2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
end
