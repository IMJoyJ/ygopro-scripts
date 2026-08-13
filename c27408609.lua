--黄金のホムンクルス
-- 效果：
-- 这张卡的攻击力·守备力上升从游戏中除外的自己的卡数量×300的数值。
function c27408609.initial_effect(c)
	-- 这张卡的攻击力上升从游戏中除外的自己的卡数量×300的数值。此处为攻击力提升效果的创建与注册。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c27408609.value)
	c:RegisterEffect(e1)
	-- 这张卡的守备力上升从游戏中除外的自己的卡数量×300的数值。此处为守备力提升效果的创建与注册。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c27408609.value)
	c:RegisterEffect(e2)
end
-- 计算这张卡攻击力/守备力的上升数值：取这张卡当前控制者除外区的卡片数量，再乘以300。
function c27408609.value(e,c)
	-- 返回当前控制者除外区的卡片数量 × 300，作为攻守上升的具体数值。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,0)*300
end
