--フォトン・サークラー
-- 效果：
-- 这张卡的战斗发生的对自己的战斗伤害变成一半。
function c64145892.initial_effect(c)
	-- 这张卡的战斗发生的对自己的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	-- 设置效果的值，使自身受到的战斗伤害变成一半
	e1:SetValue(aux.ChangeBattleDamage(0,HALF_DAMAGE))
	c:RegisterEffect(e1)
end
