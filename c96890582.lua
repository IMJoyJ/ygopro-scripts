--秒殺の暗殺者
-- 效果：
-- 这张卡的攻击力·守备力下降自己手卡数量×400的数值。
function c96890582.initial_effect(c)
	-- 这张卡的攻击力下降自己手卡数量×400的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c96890582.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
-- 定义计算攻击力与守备力变化数值的函数
function c96890582.val(e,c)
	-- 获取自身控制者的手牌数量，并返回该数量乘以-400的数值
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*(-400)
end
