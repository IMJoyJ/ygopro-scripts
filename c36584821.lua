--紅蓮魔獣 ダ・イーザ
-- 效果：
-- ①：这张卡的攻击力·守备力变成自己的除外状态的卡数量×400。
function c36584821.initial_effect(c)
	-- ①：这张卡的攻击力·守备力变成自己的除外状态的卡数量×400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(c36584821.value)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力·守备力变成自己的除外状态的卡数量×400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_DEFENSE)
	e2:SetValue(c36584821.value)
	c:RegisterEffect(e2)
end
-- 计算控制者除外区卡牌数量并乘以400作为攻击力和守备力的变更值
function c36584821.value(e,c)
	-- 获取控制者除外区的卡牌数量并乘以400
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,0)*400
end
