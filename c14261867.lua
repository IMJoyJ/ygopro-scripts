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
-- 起动效果的发动条件判定：仅当该卡可以变更为里侧守备表示且本回合尚未使用过此效果时才能发动；满足条件后为自身注册一个到回合结束前有效的使用次数标记，并设置将自身变更为里侧守备表示的操作信息。
function c14261867.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(14261867)==0 end
	c:RegisterFlagEffect(14261867,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置本次连锁的操作信息：效果处理时将对象卡（自身）变更为里侧守备表示，变更数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理时，若这张卡仍与效果关联且处于表侧表示，则将其变更为里侧守备表示。
function c14261867.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡的表示形式变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 伤害计算前触发效果的发动条件：这张卡是攻击怪兽，且其攻击对象是里侧守备表示的怪兽。
function c14261867.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判断并返回：这张卡为攻击者、存在战斗对象，且战斗对象在进行伤害计算前为里侧守备表示。
	return c==Duel.GetAttacker() and bc and bc:GetBattlePosition()==POS_FACEDOWN_DEFENSE
end
-- 效果处理时，若这张卡仍与效果关联且处于表侧表示，则赋予其一个仅在本次伤害计算阶段适用的、将攻击力固定为2400的效果。
function c14261867.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡在伤害计算时攻击力以2400计算。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(2400)
		c:RegisterEffect(e1)
	end
end
