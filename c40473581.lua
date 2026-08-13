--雷帝神
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转回合的结束阶段时回到主人的手卡。这张卡给与对方玩家的战斗伤害减半。
function c40473581.initial_effect(c)
	-- 为这张卡添加灵魂怪兽的返回手卡效果：在通常召唤成功或反转的回合结束阶段，这张卡回到持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定值设为恒为false，使这张卡永远不能通过特殊召唤方式出场。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡给与对方玩家的战斗伤害减半。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	-- 设置该战斗伤害变更效果的数值：对对方玩家造成的战斗伤害变为一半（HALF_DAMAGE）。
	e4:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e4)
end
