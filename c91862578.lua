--激昂のムカムカ
-- 效果：
-- 自己每有1张手卡，这张卡攻击力·守备力各上升400。
function c91862578.initial_effect(c)
	-- 自己每有1张手卡，这张卡攻击力·守备力各上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c91862578.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
-- 计算并返回该卡攻击力·守备力上升数值的辅助函数
function c91862578.val(e,c)
	-- 获取该卡控制者的手卡数量，并乘以400作为攻击力·守备力的上升值
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*400
end
