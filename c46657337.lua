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
-- 计算这张卡控制者手牌的数量×300，作为攻击力和守备力的上升值；该函数返回的数值供攻击力/守备力上升效果使用。
function c46657337.val(e,c)
	-- 获取这张卡控制者的手牌数量并乘以300，返回该数值作为攻击力/守备力实际上升的点数。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*300
end
