--逆ギレパンダ
-- 效果：
-- 对方场上每存在1只怪兽，这张卡的攻击力上升500点。这张卡攻击守备表示的怪兽时，若攻击力超过那个守备力，给与对方那个数值的战斗伤害。
function c9817927.initial_effect(c)
	-- 对方场上每存在1只怪兽，这张卡的攻击力上升500点。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c9817927.val)
	c:RegisterEffect(e1)
	-- 这张卡攻击守备表示的怪兽时，若攻击力超过那个守备力，给与对方那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 定义攻击力上升值的计算函数
function c9817927.val(e,c)
	-- 获取对方场上的怪兽数量，并返回该数量乘以500的数值作为攻击力上升值
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)*500
end
