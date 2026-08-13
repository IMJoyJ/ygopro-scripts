--召喚獣プルガトリオ
-- 效果：
-- 「召唤师 阿莱斯特」＋炎属性怪兽
-- ①：这张卡的攻击力上升对方场上的卡数量×200。
-- ②：这张卡可以向对方怪兽全部各作1次攻击，向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c12307878.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材为「召唤师 阿莱斯特」（卡号86120751）与1只炎属性怪兽。
	aux.AddFusionProcCodeFun(c,86120751,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_FIRE),1,true,true)
	-- ①：这张卡的攻击力上升对方场上的卡数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c12307878.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡可以向对方怪兽全部各作1次攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
-- 定义①效果中攻击力上升数值的计算函数：统计对方场上的卡牌数量，将其乘以200后作为攻击力上升值。
function c12307878.atkval(e,c)
	-- 以这张卡的控制者为视角，统计对方场上所有卡牌（怪兽区和魔法陷阱区）的数量，乘以200作为攻击力的上升数值。
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_ONFIELD)*200
end
