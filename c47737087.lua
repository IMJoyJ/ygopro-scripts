--E・HERO ランパートガンナー
-- 效果：
-- 「元素英雄 爆热女郎」＋「元素英雄 黏土侠」
-- 这只怪兽不能作融合召唤以外的特殊召唤。这张卡表侧守备表示的场合，可以用守备表示的状态直接攻击对方玩家。那个场合，这张卡的攻击力在伤害计算时变成一半。
function c47737087.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号58932615和84327329的两只怪兽为融合素材
	aux.AddFusionProcCode2(c,58932615,84327329,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果的值为过滤函数aux.fuslimit，用于限制只能通过融合召唤特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 这张卡表侧守备表示的场合，可以用守备表示的状态直接攻击对方玩家。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c47737087.dacon)
	c:RegisterEffect(e2)
	-- 这张卡表侧守备表示的场合，可以用守备表示的状态直接攻击对方玩家。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DEFENSE_ATTACK)
	c:RegisterEffect(e3)
	-- 那个场合，这张卡的攻击力在伤害计算时变成一半。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetCondition(c47737087.dacon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 当满足条件时，将该卡的攻击力设置为原来的一半
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
-- 判断当前卡是否处于守备表示
function c47737087.dacon(e)
	return e:GetHandler():IsDefensePos()
end
-- 判断是否处于伤害计算阶段且满足攻击条件
function c47737087.atkcon(e)
	-- 如果不是伤害计算阶段则返回false
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
	local c=e:GetHandler()
	-- 判断当前卡处于守备表示、是攻击怪兽、没有攻击目标且拥有直接攻击效果
	return c:IsDefensePos() and c==Duel.GetAttacker() and Duel.GetAttackTarget()==nil and c:GetEffectCount(EFFECT_DIRECT_ATTACK)==1
end
-- 将攻击力设置为原攻击力的一半（向上取整）
function c47737087.atkval(e,c)
	return math.ceil(c:GetAttack()/2)
end
