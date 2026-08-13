--アンデット・スカル・デーモン
-- 效果：
-- 「僵尸带菌者」＋调整以外的不死族怪兽2只以上
-- 自己场上表侧表示存在的不死族怪兽不会被卡的效果破坏。
function c59969392.initial_effect(c)
	-- 将该卡列为融合/同调/超量素材名单，加入关联码33420078（僵尸带菌者）。
	aux.AddMaterialCodeList(c,33420078)
	-- 添加同调召唤手续：调整必须为33420078（僵尸带菌者），调整以外需要不死族怪兽2只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,33420078),aux.NonTuner(Card.IsRace,RACE_ZOMBIE),2)
	c:EnableReviveLimit()
	-- 自己场上表侧表示存在的不死族怪兽不会被卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该效果的作用对象为场上表侧表示的不死族怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
