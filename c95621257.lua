--フレムベル・マジカル
-- 效果：
-- 只要自己场上有名字带有「正义盟军」的怪兽存在，这张卡的攻击力上升400。
function c95621257.initial_effect(c)
	-- 只要自己场上有名字带有「正义盟军」的怪兽存在，这张卡的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c95621257.atkcon)
	e1:SetValue(400)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且卡名含有「正义盟军」的卡
function c95621257.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1)
end
-- 攻击力上升效果的生效条件：自己场上存在满足过滤条件的怪兽
function c95621257.atkcon(e)
	-- 检查自己场上是否存在至少1张表侧表示且卡名含有「正义盟军」的怪兽
	return Duel.IsExistingMatchingCard(c95621257.filter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
