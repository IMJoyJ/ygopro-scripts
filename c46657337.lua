--ムカムカ
-- 效果：
-- 只要这张卡表侧表示在场上存在，控制者手上每有1张卡，这张卡的攻击力·守备力上升300。
function c46657337.initial_effect(c)
	-- 只要这张卡表侧表示在场上存在，控制者手上每有1张卡，这张卡的攻击力·守备力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c46657337.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
-- 计算控制者手牌数量并乘以300作为攻击力和守备力的提升值
function c46657337.val(e,c)
	-- 获取当前控制者手牌数量并乘以300
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*300
end
