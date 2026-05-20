--ナイトメア・ホース
-- 效果：
-- 这张卡在对方场上存在怪兽的状态下也能对对方进行直接攻击。
function c59290628.initial_effect(c)
	-- 这张卡在对方场上存在怪兽的状态下也能对对方进行直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
end
