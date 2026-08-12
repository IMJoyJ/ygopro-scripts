--竜宮の白タウナギ
-- 效果：
-- 把这张卡作为同调素材的场合，其他的同调素材怪兽必须全部是鱼族怪兽。
function c37953640.initial_effect(c)
	-- 把这张卡作为同调素材的场合，其他的同调素材怪兽必须全部是鱼族怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TUNER_MATERIAL_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetTarget(c37953640.synlimit)
	c:RegisterEffect(e1)
end
-- 限制只有鱼族怪兽才能作为同调素材
function c37953640.synlimit(e,c)
	return c:IsRace(RACE_FISH)
end
