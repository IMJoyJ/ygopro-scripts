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
-- 过滤函数，用于判断魔法·陷阱区域是否存在卡
function c40384720.dfilter(c)
	return c:GetSequence()<5
end
-- 判断对方魔法·陷阱区域是否没有卡
function c40384720.dircon(e)
	-- 对方的魔法·陷阱卡区域没有卡存在的场合
	return not Duel.IsExistingMatchingCard(c40384720.dfilter,e:GetHandlerPlayer(),0,LOCATION_SZONE,1,nil)
end
-- 伤害计算条件函数，用于判断是否满足战斗伤害变更的条件
function c40384720.rdcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	-- 攻击目标为空时触发
	return Duel.GetAttackTarget()==nil
		-- 自身未发动过直接攻击且己方怪兽区有怪兽存在时触发
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 当受到战斗伤害时，将伤害值设为自身原本攻击力
function c40384720.rdval(e,damp)
	if damp==1-e:GetHandlerPlayer() then
		return e:GetHandler():GetBaseAttack()
	else return -1 end
end
