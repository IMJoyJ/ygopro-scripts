--軍隊ピラニア
-- 效果：
-- 这张卡对对方进行直接攻击时战斗伤害加倍。
function c50823978.initial_effect(c)
	-- 这张卡对对方进行直接攻击时战斗伤害加倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetCondition(c50823978.dcon)
	-- 设置战斗伤害变更效果：当此卡对对方造成战斗伤害时，将对方受到的战斗伤害翻倍。
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
end
-- 定义发动条件子函数：判断当前是否为此卡对对方进行直接攻击。
function c50823978.dcon(e)
	-- 检查攻击目标是否为空，若为空则说明是直接攻击，返回真。
	return Duel.GetAttackTarget()==nil
end
