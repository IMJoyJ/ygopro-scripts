--ロード・オブ・ドラゴン－ドラゴンの支配者－
-- 效果：
-- ①：只要这张卡在怪兽区域存在，双方不能把场上的龙族怪兽作为效果的对象。
function c17985575.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，双方不能把场上的龙族怪兽作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c17985575.etarget)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
-- 设置效果目标为场上的龙族怪兽
function c17985575.etarget(e,c)
	return c:IsRace(RACE_DRAGON)
end
