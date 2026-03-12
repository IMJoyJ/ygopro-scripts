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
-- 检索满足条件的场上「鹰身女郎」数量并乘以300作为攻击力和守备力的提升值
function c52040216.val(e,c)
	-- 统计以当前控制者视角在场上的「鹰身女郎」数量，并乘以300
	return Duel.GetMatchingGroupCount(c52040216.filter,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*300
end
-- 过滤函数，用于判断一张卡是否为表侧表示的「鹰身女郎」
function c52040216.filter(c)
	return c:IsFaceup() and c:IsCode(76812113)
end
