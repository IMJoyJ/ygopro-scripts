--ホルスのしもべ
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，对方的魔法·陷阱·怪兽的效果不能以「荷鲁斯之黑炎龙（包括全部等级）」的怪兽为对象。
function c9264485.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，对方的魔法·陷阱·怪兽的效果不能以「荷鲁斯之黑炎龙（包括全部等级）」的怪兽为对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果影响的目标为字段名含有「荷鲁斯之黑炎龙」的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x119d))
	-- 设置限制效果来源为对方玩家，使其不能成为对方卡片效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
end
