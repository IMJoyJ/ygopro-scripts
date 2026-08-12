--イグザリオン・ユニバース
-- 效果：
-- ①：这张卡向守备表示怪兽攻击的战斗步骤才能发动。直到回合结束时，这张卡的攻击力下降400，这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c63749102.initial_effect(c)
	-- ①：这张卡向守备表示怪兽攻击的战斗步骤才能发动。直到回合结束时，这张卡的攻击力下降400，这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63749102,0))  --"攻击下降"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMING_BATTLE_PHASE)
	e1:SetCondition(c63749102.atkcon)
	e1:SetOperation(c63749102.atkop)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件函数，用于判断是否满足在向守备表示怪兽攻击的战斗步骤发动的时点
function c63749102.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 必须在连锁1发动，且自身是攻击怪兽，且攻击对象存在并处于守备表示
	return Duel.GetCurrentChain()==0 and e:GetHandler()==Duel.GetAttacker() and Duel.GetAttackTarget() and Duel.GetAttackTarget():IsDefensePos()
end
-- 定义效果的处理函数，使自身攻击力下降400并获得贯穿效果，持续到回合结束
function c63749102.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 直到回合结束时，这张卡的攻击力下降400
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(-400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_PIERCE)
		c:RegisterEffect(e2)
	end
end
