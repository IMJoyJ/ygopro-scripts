--阿修羅
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转回合的结束阶段时回到主人的手卡。可以对对方场上的全部怪兽攻击1次。
function c2134346.initial_effect(c)
	-- 使该卡在召唤或反转召唤回合的结束阶段回到手卡
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 可以对对方场上的全部怪兽攻击1次
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
