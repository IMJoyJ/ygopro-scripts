--起動兵士デッドリボルバー
-- 效果：
-- 只要自己场上有名字带有「零件」的怪兽表侧表示存在，这张卡的攻击力上升2000。
function c13316346.initial_effect(c)
	-- 只要自己场上有名字带有「零件」的怪兽表侧表示存在，这张卡的攻击力上升2000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c13316346.atkcon)
	e1:SetValue(2000)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否存在满足条件的怪兽
function c13316346.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x51)
end
-- 效果条件函数，用于判断是否满足攻击力上升的效果触发条件
function c13316346.atkcon(e)
	-- 检索满足条件的卡片组，检查自己场上是否存在至少1张表侧表示的「零件」怪兽
	return Duel.IsExistingMatchingCard(c13316346.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
