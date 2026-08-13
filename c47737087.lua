--E・HERO ランパートガンナー
-- 效果：
-- 「元素英雄 爆热女郎」＋「元素英雄 黏土侠」
-- 这只怪兽不能作融合召唤以外的特殊召唤。这张卡表侧守备表示的场合，可以用守备表示的状态直接攻击对方玩家。那个场合，这张卡的攻击力在伤害计算时变成一半。
function c47737087.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以「元素英雄 爆热女郎」和「元素英雄 黏土侠」为融合素材，并允许使用融合素材代用品。
	aux.AddFusionProcCode2(c,58932615,84327329,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件效果的判定值设为aux.fuslimit，即仅当召唤类型为融合召唤时才允许特殊召唤，从而限制其他特殊召唤方式。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 这张卡表侧守备表示的场合，可以用守备表示的状态直接攻击对方玩家。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c47737087.dacon)
	c:RegisterEffect(e2)
	-- 可以用守备表示的状态直接攻击对方玩家。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DEFENSE_ATTACK)
	c:RegisterEffect(e3)
	-- 此外，这张卡表侧守备表示的场合，对方不能选择这张卡以外的怪兽作为攻击对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetCondition(c47737087.dacon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 那个场合，这张卡的攻击力在伤害计算时变成一半。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SET_ATTACK_FINAL)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c47737087.atkcon)
	e5:SetValue(c47737087.atkval)
	c:RegisterEffect(e5)
end
c47737087.material_setcode=0x8
-- 条件函数：判断这张卡是否为表侧守备表示，作为直接攻击和攻击对象限制效果的共同条件。
function c47737087.dacon(e)
	return e:GetHandler():IsDefensePos()
end
-- 攻击力减半效果的发动条件：仅在伤害计算阶段，这张卡为表侧守备表示、以直接攻击状态攻击对方玩家（攻击对象为空）且拥有直接攻击效果时满足。
function c47737087.atkcon(e)
	-- 若当前阶段不是伤害计算阶段，则返回false，确保攻击力减半效果只在伤害计算时适用。
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
	local c=e:GetHandler()
	-- 判定具体条件：这张卡表侧守备表示、是攻击者、攻击目标为空（直接攻击）且自身有1个EFFECT_DIRECT_ATTACK效果。
	return c:IsDefensePos() and c==Duel.GetAttacker() and Duel.GetAttackTarget()==nil and c:GetEffectCount(EFFECT_DIRECT_ATTACK)==1
end
-- 攻击力计算函数：返回这张卡当前攻击力除以2后的向上取整值，作为伤害计算时的攻击力。
function c47737087.atkval(e,c)
	return math.ceil(c:GetAttack()/2)
end
