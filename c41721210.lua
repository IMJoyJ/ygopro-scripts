--竜騎士ブラック・マジシャン
-- 效果：
-- 「黑魔术师」＋龙族怪兽
-- ①：这张卡的卡名只要在场上·墓地存在当作「黑魔术师」使用。
-- ②：只要这张卡在怪兽区域存在，自己场上的魔法·陷阱卡不会被对方的效果破坏，对方不能把那些作为效果的对象。
function c41721210.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为46986414的怪兽和1个龙族怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,46986414,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),1,true,true)
	-- 使该卡在场上或墓地存在时视为「黑魔术师」
	aux.EnableChangeCode(c,46986414,LOCATION_MZONE+LOCATION_GRAVE)
	-- 只要这张卡在怪兽区域存在，自己场上的魔法·陷阱卡不会被对方的效果破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设置效果目标为场上所有的魔法·陷阱卡
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPELL+TYPE_TRAP))
	-- 设置该效果的过滤函数为aux.indoval，用于判断是否不会被对方效果破坏
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置该效果的过滤函数为aux.tgoval，用于判断是否不能成为对方效果的对象
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end
