--氷弾使いレイス
-- 效果：
-- ①：这张卡不会被和4星以上的怪兽的战斗破坏。
function c30276969.initial_effect(c)
	-- ①：这张卡不会被和4星以上的怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c30276969.indes)
	c:RegisterEffect(e1)
end
-- 判断自身是否为4星以上，用于决定是否免疫战斗破坏效果
function c30276969.indes(e,c)
	return c:IsLevelAbove(4)
end
