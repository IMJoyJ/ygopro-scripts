--魔法のランプ
-- 效果：
-- 这张卡可以直接攻击对方玩家。
function c98049915.initial_effect(c)
	-- 这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
end
