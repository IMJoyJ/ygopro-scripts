--D・ビデオン
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：这张卡的攻击力上升这张卡装备的装备卡数量×800的数值。
-- ●守备表示：这张卡的守备力上升这张卡装备的装备卡数量×800的数值。
function c84592800.initial_effect(c)
	-- ●攻击表示：这张卡的攻击力上升这张卡装备的装备卡数量×800的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c84592800.cona)
	e1:SetValue(c84592800.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetCondition(c84592800.cond)
	c:RegisterEffect(e2)
end
-- 判断自身是否处于攻击表示，作为攻击力上升效果的适用条件
function c84592800.cona(e)
	return e:GetHandler():IsAttackPos()
end
-- 判断自身是否处于守备表示，作为守备力上升效果的适用条件
function c84592800.cond(e)
	return e:GetHandler():IsDefensePos()
end
-- 计算并返回自身装备的装备卡数量乘以800的数值，作为攻击力或守备力的上升值
function c84592800.val(e,c)
	return c:GetEquipCount()*800
end
