--クリアー・バイス・ドラゴン
-- 效果：
-- ①：只要这张卡在怪兽区域存在，「清透世界」的效果对自己不适用。
-- ②：这张卡的攻击力只在向对方怪兽攻击的伤害计算时变成那只对方怪兽的攻击力的2倍。
-- ③：场上的这张卡被对方的效果破坏的场合，可以作为代替把自己1张手卡丢弃。
function c97811903.initial_effect(c)
	-- 在系统中记录这张卡关联了「清透世界」的卡名
	aux.AddCodeList(c,33900648)
	-- ②：这张卡的攻击力只在向对方怪兽攻击的伤害计算时变成那只对方怪兽的攻击力的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c97811903.atkcon)
	e1:SetValue(c97811903.atkval)
	c:RegisterEffect(e1)
	-- ③：场上的这张卡被对方的效果破坏的场合，可以作为代替把自己1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(c97811903.reptg)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，「清透世界」的效果对自己不适用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetCode(97811903)
	c:RegisterEffect(e3)
end
-- 攻击力变化效果的条件函数：必须在伤害计算时，且自身是攻击怪兽，且存在攻击对象
function c97811903.atkcon(e)
	-- 判断当前阶段是否为伤害计算时
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		-- 并且自身是攻击怪兽，且存在攻击对象（即向对方怪兽攻击）
		and e:GetHandler()==Duel.GetAttacker() and Duel.GetAttackTarget()
end
-- 攻击力变化数值的计算函数：返回攻击对象攻击力的2倍
function c97811903.atkval(e,c)
	-- 获取攻击对象的当前攻击力并乘以2
	return Duel.GetAttackTarget():GetAttack()*2
end
-- 代替破坏效果的目标与条件检查：自身因对方效果破坏，且手卡有1张以上
function c97811903.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
		-- 并且我方手卡数量大于0
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	-- 询问玩家是否适用代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 让玩家选择并丢弃1张手卡
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		return true
	else return false end
end
