--マジシャンズ・ヴァルキリア
-- 效果：
-- ①：只要这张卡在怪兽区域存在，对方怪兽不能选择其他的魔法师族怪兽作为攻击对象。
function c80304126.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，对方怪兽不能选择其他的魔法师族怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c80304126.tg)
	c:RegisterEffect(e1)
end
-- 过滤出除自身以外、表侧表示的魔法师族怪兽作为不能被选择为攻击对象的目标
function c80304126.tg(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
