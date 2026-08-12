--召喚獣コキュートス
-- 效果：
-- 「召唤师 阿莱斯特」＋水属性怪兽
-- ①：场上的这张卡不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：这张卡可以用表侧守备表示的状态作出攻击。那个场合，攻击力数值适用进行伤害计算。
function c85908279.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，素材为「召唤师 阿莱斯特」和1只水属性怪兽
	aux.AddFusionProcCodeFun(c,86120751,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_WATER),1,true,true)
	-- ①：场上的这张卡不会成为对方的效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置抗性过滤函数，使其不会成为对方的效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	-- 设置抗性过滤函数，使其不会被对方的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：这张卡可以用表侧守备表示的状态作出攻击。那个场合，攻击力数值适用进行伤害计算。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DEFENSE_ATTACK)
	c:RegisterEffect(e3)
end
