--ソニック・シューター
-- 效果：
-- 对方的魔法·陷阱卡区域没有卡存在的场合，这张卡可以直接攻击对方玩家。这个时候，给与对方玩家的战斗伤害变成这张卡的原本攻击力的数值。
function c40384720.initial_effect(c)
	-- 对方的魔法·陷阱卡区域没有卡存在的场合，这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c40384720.dircon)
	c:RegisterEffect(e1)
	-- 这个时候，给与对方玩家的战斗伤害变成这张卡的原本攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(c40384720.rdcon)
	e2:SetValue(c40384720.rdval)
	c:RegisterEffect(e2)
end
-- 判断卡片是否处于通常魔法陷阱区域：返回其区域序号是否小于5（排除场地魔法格），用于筛选对方魔法陷阱区的卡。
function c40384720.dfilter(c)
	return c:GetSequence()<5
end
-- 直接攻击的发动条件：对方的魔法陷阱区域（通常后场，不含场地格）不存在任何卡。
function c40384720.dircon(e)
	-- 检查对方场上是否存在满足dfilter条件的卡；若不存在（not）则返回真，即对方的魔法陷阱区没有卡。
	return not Duel.IsExistingMatchingCard(c40384720.dfilter,e:GetHandlerPlayer(),0,LOCATION_SZONE,1,nil)
end
-- 伤害变更效果的适用条件：正在进行直接攻击（无攻击对象）、该卡拥有的直接攻击效果数量不足2个，且对方场上有怪兽存在，以此确保这是由本卡效果产生的直接攻击。
function c40384720.rdcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	-- 判断当前攻击目标为空（Duel.GetAttackTarget()==nil），即正在进行直接攻击。
	return Duel.GetAttackTarget()==nil
		-- 附加条件：该卡受到的直接攻击效果数量少于2（避免重复叠加），且对方场上存在怪兽，确认此直接攻击是由本卡效果导致的（而不是对方场上无怪兽时的普通直接攻击）。
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 计算变更后的战斗伤害：若受到伤害的是对方玩家（damp为对方的玩家），则返回该卡的原本攻击力作为战斗伤害；否则返回-1表示不改变伤害。
function c40384720.rdval(e,damp)
	if damp==1-e:GetHandlerPlayer() then
		return e:GetHandler():GetBaseAttack()
	else return -1 end
end
