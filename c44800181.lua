--コンボマスター
-- 效果：
-- 这张卡在场上表侧表示存在时自己回合的主要阶段一有连锁发生的场合，只在这个回合这张卡可以在同1次战斗阶段作2次攻击。
function c44800181.initial_effect(c)
	-- 这张卡在场上表侧表示存在时自己回合的主要阶段一有连锁发生的场合，只在这个回合这张卡可以在同1次战斗阶段作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c44800181.chop)
	c:RegisterEffect(e1)
	-- 这张卡在场上表侧表示存在时自己回合的主要阶段一有连锁发生的场合，只在这个回合这张卡可以在同1次战斗阶段作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(c44800181.atkcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 当连锁发动时，若当前阶段为主要阶段一且为使用者回合、连锁数大于1，则为该卡注册一个在结束阶段重置的标识效果
function c44800181.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段一、是否为使用者回合、连锁数是否大于1
	if Duel.GetCurrentPhase()==PHASE_MAIN1 and Duel.GetTurnPlayer()==tp and Duel.GetCurrentChain()>1
		and e:GetHandler():GetFlagEffect(44800181)==0 then
		e:GetHandler():RegisterFlagEffect(44800181,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判断该卡是否拥有标识效果，用于决定是否可以进行额外攻击
function c44800181.atkcon(e)
	return e:GetHandler():GetFlagEffect(44800181)~=0
end
