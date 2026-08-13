--ハーピィズペット竜
-- 效果：
-- ①：这张卡的攻击力·守备力上升场上的「鹰身女郎」数量×300。
function c52040216.initial_effect(c)
	-- ①：这张卡的攻击力·守备力上升场上的「鹰身女郎」数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c52040216.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
-- 计算此卡攻击力/守备力上升的数值：统计场上表侧表示「鹰身女郎」的数量并乘以300。
function c52040216.val(e,c)
	-- 调用过滤函数统计双方场上表侧表示「鹰身女郎」的数量，乘以300作为攻击力/守备力的增减值。
	return Duel.GetMatchingGroupCount(c52040216.filter,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*300
end
-- 过滤函数：判断卡片是否为表侧表示且卡号是76812113（「鹰身女郎」）。
function c52040216.filter(c)
	return c:IsFaceup() and c:IsCode(76812113)
end
