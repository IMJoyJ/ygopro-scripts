--ナチュル・ドラゴンフライ
-- 效果：
-- 这张卡不会被和攻击力2000以上的怪兽的战斗破坏。这张卡的攻击力上升自己墓地存在的名字带有「自然」的怪兽数量×200的数值。
function c70083723.initial_effect(c)
	-- 这张卡不会被和攻击力2000以上的怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c70083723.indes)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力上升自己墓地存在的名字带有「自然」的怪兽数量×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c70083723.atkval)
	c:RegisterEffect(e1)
end
-- 战斗破坏抗性的判定函数，若与该卡战斗的怪兽攻击力（或守备表示攻击时的守备力）在2000以上，则该卡不被战斗破坏
function c70083723.indes(e,c)
	-- 判断与该卡战斗的怪兽是否处于守备表示且为攻击宣言怪兽（即守备表示攻击的情况）
	if c:IsDefensePos() and Duel.GetAttacker()==c then
		return c:IsDefenseAbove(2000)
	else
		return c:IsAttackAbove(2000)
	end
end
-- 过滤条件：名字带有「自然」的怪兽卡
function c70083723.filter(c)
	return c:IsSetCard(0x2a) and c:IsType(TYPE_MONSTER)
end
-- 攻击力上升值的计算函数，返回自己墓地中「自然」怪兽数量×200的数值
function c70083723.atkval(e,c)
	-- 计算自己墓地中名字带有「自然」的怪兽数量并乘以200，作为攻击力上升的数值返回
	return Duel.GetMatchingGroupCount(c70083723.filter,c:GetControler(),LOCATION_GRAVE,0,nil)*200
end
