--因幡之白兎
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到主人的手卡。对方场上存在怪兽也只能直接攻击对方玩家。
function c77084837.initial_effect(c)
	-- 为自身注册在通常召唤或翻转的回合结束阶段回到持有者手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为始终不满足，从而实现无法特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 对方场上存在怪兽也只能直接攻击对方玩家。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e4)
	-- 对方场上存在怪兽也只能直接攻击对方玩家。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
