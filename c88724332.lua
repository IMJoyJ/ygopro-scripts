--ナイト・ドラゴリッチ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，幻龙族以外的从卡组·额外卡组特殊召唤的攻击表示怪兽变成守备表示。
-- ②：只要这张卡在怪兽区域存在，幻龙族以外的从卡组·额外卡组特殊召唤的怪兽的守备力下降那个原本守备力数值。
function c88724332.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，幻龙族以外的从卡组·额外卡组特殊召唤的攻击表示怪兽变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_POSITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c88724332.target)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，幻龙族以外的从卡组·额外卡组特殊召唤的怪兽的守备力下降那个原本守备力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c88724332.deftg)
	e2:SetValue(c88724332.defval)
	c:RegisterEffect(e2)
end
-- 过滤出场上表侧表示、非幻龙族、且从卡组或额外卡组特殊召唤的怪兽作为效果①的适用对象
function c88724332.target(e,c)
	return c:IsFaceup() and not c:IsRace(RACE_WYRM)
		and c:IsSummonType(SUMMON_TYPE_SPECIAL)
		and c:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤出场上表侧表示、非幻龙族、且从卡组或额外卡组特殊召唤的怪兽作为效果②的适用对象
function c88724332.deftg(e,c)
	return c:IsFaceup() and not c:IsRace(RACE_WYRM)
		and c:IsSummonType(SUMMON_TYPE_SPECIAL)
		and c:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 获取目标怪兽的原本守备力并返回其负值，使守备力下降该数值
function c88724332.defval(e,c)
	return -c:GetBaseDefense()
end
