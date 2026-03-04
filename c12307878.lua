--召喚獣プルガトリオ
-- 效果：
-- 「召唤师 阿莱斯特」＋炎属性怪兽
-- ①：这张卡的攻击力上升对方场上的卡数量×200。
-- ②：这张卡可以向对方怪兽全部各作1次攻击，向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c12307878.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为86120751的怪兽和1个炎属性怪兽作为融合素材
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
	-- 向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
-- 计算攻击力上升值，返回对方场上卡数量乘以200的结果
function c12307878.atkval(e,c)
	-- 获取对方场上卡的数量并乘以200作为攻击力上升值
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_ONFIELD)*200
end
