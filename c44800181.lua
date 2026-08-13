--コンボマスター
-- 效果：
-- 这张卡在场上表侧表示存在时自己回合的主要阶段一有连锁发生的场合，只在这个回合这张卡可以在同1次战斗阶段作2次攻击。
function c44800181.initial_effect(c)
	-- 这张卡在场上表侧表示存在时自己回合的主要阶段一有连锁发生的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c44800181.chop)
	c:RegisterEffect(e1)
	-- 只在这个回合这张卡可以在同1次战斗阶段作2次攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(c44800181.atkcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 连锁发生事件处理：若当前阶段为自己回合的主要阶段一且当前连锁序号大于1，并且本卡尚未记录过该回合的触发标志，则为本卡注册44800181标志，该标志在离场、回合结束等标准重置条件下清除，用于记录本回合已满足触发条件。
function c44800181.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足记录条件：当前阶段为PHASE_MAIN1，当前回合玩家是本卡控制者，且当前连锁序号大于1。
	if Duel.GetCurrentPhase()==PHASE_MAIN1 and Duel.GetTurnPlayer()==tp and Duel.GetCurrentChain()>1
		and e:GetHandler():GetFlagEffect(44800181)==0 then
		e:GetHandler():RegisterFlagEffect(44800181,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 额外攻击次数的条件判定：检查本卡是否拥有44800181标志（即本回合是否已经满足触发条件），若拥有则允许额外攻击1次。
function c44800181.atkcon(e)
	return e:GetHandler():GetFlagEffect(44800181)~=0
end
