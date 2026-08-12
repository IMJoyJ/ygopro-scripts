--X・HERO ドレッドバスター
-- 效果：
-- 「英雄」怪兽2只以上
-- ①：这张卡以及这张卡所连接区的「英雄」怪兽的攻击力上升自己墓地的「英雄」怪兽种类×100。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c63813056.initial_effect(c)
	-- 添加连接召唤手续：使用2只以上的「英雄」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x8),2)
	c:EnableReviveLimit()
	-- ①：这张卡以及这张卡所连接区的「英雄」怪兽的攻击力上升自己墓地的「英雄」怪兽种类×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c63813056.atktg)
	e1:SetValue(c63813056.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 确定效果影响的目标：这张卡自身，以及这张卡所连接区的表侧表示「英雄」怪兽
function c63813056.atktg(e,c)
	return c==e:GetHandler()
		or c:IsFaceup() and c:IsSetCard(0x8) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 过滤自己墓地中的「英雄」怪兽
function c63813056.atkfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER)
end
-- 计算攻击力上升的数值：自己墓地的「英雄」怪兽种类数量×100
function c63813056.atkval(e,c)
	-- 获取自己墓地中的「英雄」怪兽并计算不同卡名的种类数量，最后乘以100作为攻击力上升值
	return Duel.GetMatchingGroup(c63813056.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)*100
end
