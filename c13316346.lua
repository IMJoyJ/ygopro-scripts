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
-- 筛选满足“表侧表示且名字带有「零件」”的怪兽，作为攻击力上升条件的判定对象。
function c13316346.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x51)
end
-- 判定自己场上是否存在至少1只表侧表示且名字带有「零件」的怪兽，以决定是否适用攻击力上升效果。
function c13316346.atkcon(e)
	-- 检查自己怪兽区域是否存在至少1只表侧表示且名字带有「零件」的怪兽；存在时条件成立，攻击力上升效果适用。
	return Duel.IsExistingMatchingCard(c13316346.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
