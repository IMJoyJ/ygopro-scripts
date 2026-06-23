--ブンボーグ008
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「文具电子人」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- ①：这张卡的攻击力上升自己墓地的「文具电子人」卡数量×500。
-- ②：只要这张卡在怪兽区域存在，对方不能把其他的「文具电子人」卡作为效果的对象。
-- ③：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c24573625.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「文具电子人」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c24573625.splimcon)
	e2:SetTarget(c24573625.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击力上升自己墓地的「文具电子人」卡数量×500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c24573625.value)
	c:RegisterEffect(e3)
	-- ③：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ②：只要这张卡在怪兽区域存在，对方不能把其他的「文具电子人」卡作为效果的对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e5:SetTarget(c24573625.tglimit)
	-- 设置效果值为过滤函数，用于判断目标是否不能成为对方效果的对象
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
-- 条件函数：判断该卡是否处于被宣言禁止状态
function c24573625.splimcon(e)
	return not e:GetHandler():IsForbidden()
end
-- 限制函数：判断召唤的怪兽是否不是文具电子人且为灵摆召唤
function c24573625.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xab) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 计算函数：返回自己墓地的文具电子人卡数量并乘以500作为攻击力提升值
function c24573625.value(e,c)
	-- 检索满足条件的卡片组并计算数量，用于计算攻击力提升值
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0xab)*500
end
-- 目标限制函数：判断目标是否为文具电子人且不是该卡本身
function c24573625.tglimit(e,c)
	return c:IsSetCard(0xab) and c~=e:GetHandler()
end
