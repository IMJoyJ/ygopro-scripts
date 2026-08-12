--コンボファイター
-- 效果：
-- 这张卡在场上表侧表示存在时自己回合的主要阶段一有连锁发生的场合，只在这个回合这张卡可以在同1次战斗阶段作2次攻击。
function c8806072.initial_effect(c)
	-- 这张卡在场上表侧表示存在时自己回合的主要阶段一有连锁发生的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c8806072.chop)
	c:RegisterEffect(e1)
	-- 只在这个回合这张卡可以在同1次战斗阶段作2次攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(c8806072.atkcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 在自己回合的主要阶段1发生连锁时，为自身注册一个在回合结束前有效的标识
function c8806072.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己回合的主要阶段1，且当前处理的连锁数大于1（即有连锁发生）
	if Duel.GetCurrentPhase()==PHASE_MAIN1 and Duel.GetTurnPlayer()==tp and Duel.GetCurrentChain()>1
		and e:GetHandler():GetFlagEffect(8806072)==0 then
		e:GetHandler():RegisterFlagEffect(8806072,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判断自身是否存在因连锁发生而注册的标识，以此作为获得追加攻击效果的条件
function c8806072.atkcon(e)
	return e:GetHandler():GetFlagEffect(8806072)~=0
end
