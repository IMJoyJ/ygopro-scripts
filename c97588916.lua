--ブンボーグ007
-- 效果：
-- ←10 【灵摆】 10→
-- ①：自己不是「文具电子人」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- ①：这张卡的攻击力上升自己墓地的「文具电子人」卡数量×500。
-- ②：只要这张卡在怪兽区域存在，对方不能把其他的「文具电子人」怪兽作为攻击对象。
-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c97588916.initial_effect(c)
	-- 初始化并注册灵摆怪兽的灵摆召唤和灵摆卡发动效果
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「文具电子人」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c97588916.splimcon)
	e2:SetTarget(c97588916.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击力上升自己墓地的「文具电子人」卡数量×500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c97588916.value)
	c:RegisterEffect(e3)
	-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e5)
	-- ②：只要这张卡在怪兽区域存在，对方不能把其他的「文具电子人」怪兽作为攻击对象。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e6:SetValue(c97588916.atlimit)
	c:RegisterEffect(e6)
end
-- 灵摆限制效果的生效条件：这张卡在灵摆区域且未被宣告禁止
function c97588916.splimcon(e)
	return not e:GetHandler():IsForbidden()
end
-- 限制玩家不能灵摆召唤「文具电子人」以外的怪兽
function c97588916.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xab) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 计算攻击力上升数值的函数，返回自己墓地「文具电子人」卡数量乘以500的值
function c97588916.value(e,c)
	-- 获取自己墓地中「文具电子人」卡片的数量并乘以500
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0xab)*500
end
-- 定义不能被选择为攻击对象的怪兽条件：表侧表示、属于「文具电子人」系列且不是这张卡自身
function c97588916.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0xab) and c~=e:GetHandler()
end
