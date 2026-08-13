--幻奏の音女アリア
-- 效果：
-- ①：只要特殊召唤的这张卡在怪兽区域存在，自己场上的「幻奏」怪兽不会成为效果的对象，不会被战斗破坏。
function c40502912.initial_effect(c)
	-- 对应效果原文：①：只要特殊召唤的这张卡在怪兽区域存在，自己场上的「幻奏」怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤出己方场上卡名属于「幻奏」（0x9b）的怪兽，作为本效果适用的对象。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x9b))
	e1:SetCondition(c40502912.tgcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e2)
end
-- 效果适用条件：这张卡是以特殊召唤方式出场的怪兽；结合效果范围为怪兽区域，即满足“特殊召唤的这张卡在怪兽区域存在”。
function c40502912.tgcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
