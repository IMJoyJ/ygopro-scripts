--軍隊ピラニア
-- 效果：
-- 这张卡对对方进行直接攻击时战斗伤害加倍。
function c50823978.initial_effect(c)
	-- 这张卡对对方进行直接攻击时战斗伤害加倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetCondition(c50823978.dcon)
	-- 设置效果值为将受到的战斗伤害变为两倍
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
end
-- 定义条件函数，判断是否为直接攻击
function c50823978.dcon(e)
	-- 当攻击没有目标怪兽时（即直接攻击）效果适用
	return Duel.GetAttackTarget()==nil
end
