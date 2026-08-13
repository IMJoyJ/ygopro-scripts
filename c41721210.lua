--竜騎士ブラック・マジシャン
-- 效果：
-- 「黑魔术师」＋龙族怪兽
-- ①：这张卡的卡名只要在场上·墓地存在当作「黑魔术师」使用。
-- ②：只要这张卡在怪兽区域存在，自己场上的魔法·陷阱卡不会被对方的效果破坏，对方不能把那些作为效果的对象。
function c41721210.initial_effect(c)
	c:EnableReviveLimit()
	-- 为此卡添加融合召唤手续：以「黑魔术师」（卡号46986414）和1只龙族怪兽作为融合素材。
	aux.AddFusionProcCodeFun(c,46986414,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),1,true,true)
	-- 为此卡注册卡名变更效果：这张卡在场上怪兽区域或墓地存在时，卡名当作「黑魔术师」使用。
	aux.EnableChangeCode(c,46986414,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：只要这张卡在怪兽区域存在，自己场上的魔法·陷阱卡不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设定该效果的保护对象为自己场上的魔法·陷阱卡（通过类型过滤）。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPELL+TYPE_TRAP))
	-- 设定该效果仅针对对方发动的效果生效，即自己场上的魔法·陷阱卡不会被对方的效果破坏。
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设定该效果使自己场上的魔法·陷阱卡不能成为对方的效果的对象。
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end
