--武神器－タルタ
-- 效果：
-- 只要这张卡在场上表侧表示存在，这张卡以外的自己场上的兽族·兽战士族·鸟兽族怪兽不会被战斗破坏。
function c32202803.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，这张卡以外的自己场上的兽族·兽战士族·鸟兽族怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c32202803.targt)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
-- 检查目标怪兽是否为兽族·兽战士族·鸟兽族且不是该卡本身
function c32202803.targt(e,c)
	return c~=e:GetHandler() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
end
