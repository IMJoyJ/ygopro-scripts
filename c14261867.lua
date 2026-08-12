--八つ手サソリ
-- 效果：
-- 这张卡1个回合可以有1次变回里侧守备表示。这张卡攻击对方的里侧守备表示的怪兽的场合，这张卡在伤害计算时攻击力以2400计算。
function c14261867.initial_effect(c)
	-- 这张卡1个回合可以有1次变回里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14261867,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c14261867.target)
	e1:SetOperation(c14261867.operation)
	c:RegisterEffect(e1)
	-- 这张卡攻击对方的里侧守备表示的怪兽的场合，这张卡在伤害计算时攻击力以2400计算。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14261867,1))  --"攻击变化"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(c14261867.atkcon)
	e2:SetOperation(c14261867.atkop)
	c:RegisterEffect(e2)
end
-- 判断是否可以发动变回里侧守备表示的效果
function c14261867.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(14261867)==0 end
	c:RegisterFlagEffect(14261867,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁操作信息，表示将要改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 执行变回里侧守备表示的效果操作
function c14261867.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将目标怪兽改变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 判断是否满足攻击力变化的条件
function c14261867.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 确认攻击怪兽是自己且攻击目标为里侧守备表示
	return c==Duel.GetAttacker() and bc and bc:GetBattlePosition()==POS_FACEDOWN_DEFENSE
end
-- 执行攻击力变化的效果操作
function c14261867.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将该怪兽在伤害计算时的攻击力设为2400
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(2400)
		c:RegisterEffect(e1)
	end
end
