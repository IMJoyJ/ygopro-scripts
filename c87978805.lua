--寄生体ダニー
-- 效果：
-- 这张卡的攻击力·守备力是场上的衍生物的数量×500的数值。
function c87978805.initial_effect(c)
	-- 这张卡的攻击力是场上的衍生物的数量×500的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(c87978805.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
end
-- 计算并返回该卡攻击力·守备力数值的辅助函数
function c87978805.val(e,c)
	-- 获取双方场上怪兽区域的衍生物数量，并乘以500作为返回值
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_TOKEN)*500
end
