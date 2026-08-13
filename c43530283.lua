--勇気の砂時計
-- 效果：
-- 这张卡召唤·反转召唤成功时，这张卡的原本的攻击力·守备力直到下次的自己回合的结束阶段时变成一半。那之后，这张卡的原本的攻击力·守备力变成2倍。
function c43530283.initial_effect(c)
	-- 这张卡召唤·反转召唤成功时，这张卡的原本的攻击力·守备力直到下次的自己回合的结束阶段时变成一半。那之后，这张卡的原本的攻击力·守备力变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43530283,0))  --"攻守变化"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c43530283.adop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 召唤·反转召唤成功时的效果处理：若此卡仍表侧表示且与发动效果关联，则给它注册暂时改变原本攻击力和原本守备力的效果，并通过注册不同重置次数的标记来控制“变成一半”的持续时间（自己回合发动记2次自己回合结束阶段，对方回合发动记1次），之后切换为2倍。
function c43530283.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的原本的攻击力直到下次的自己回合的结束阶段时变成一半。那之后，这张卡的原本的攻击力变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(c43530283.atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
		e2:SetValue(c43530283.defval)
		c:RegisterEffect(e2)
		-- 判断当前回合玩家是否为发动效果的玩家（即此卡的控制者），以决定标记的持续结束阶段次数：自己回合为2，对方回合为1。
		if Duel.GetTurnPlayer()==tp then
			c:RegisterFlagEffect(43530283,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,2)
		else
			c:RegisterFlagEffect(43530283,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
		end
	end
end
-- 根据此卡是否存在标记来决定原本攻击力的数值：存在标记时返回原本攻击力的一半（向上取整），不存在标记时返回原本攻击力的2倍。
function c43530283.atkval(e,c)
	if c:GetFlagEffect(43530283)==0 then
		return c:GetBaseAttack()*2
	else
		return math.ceil(c:GetBaseAttack()/2)
	end
end
-- 根据此卡是否存在标记来决定原本守备力的数值：存在标记时返回原本守备力的一半（向上取整），不存在标记时返回原本守备力的2倍。
function c43530283.defval(e,c)
	if c:GetFlagEffect(43530283)==0 then
		return c:GetBaseDefense()*2
	else
		return math.ceil(c:GetBaseDefense()/2)
	end
end
