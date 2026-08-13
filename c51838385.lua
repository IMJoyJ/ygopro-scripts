--ナイトメアテーベ
-- 效果：
-- ①：自己手卡和自己的魔法与陷阱区域没有卡存在的场合，这张卡的攻击力上升1500。
function c51838385.initial_effect(c)
	-- ①：自己手卡和自己的魔法与陷阱区域没有卡存在的场合，这张卡的攻击力上升1500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c51838385.atkcon)
	e1:SetValue(1500)
	c:RegisterEffect(e1)
end
-- 攻击力上升效果的条件判定函数：检查这张卡的控制者手卡以及魔法与陷阱区域是否没有任何卡存在，若满足则攻击力上升效果适用。
function c51838385.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 统计这张卡的控制者手牌区域存在的卡的数量。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		-- 统计这张卡的控制者魔法与陷阱区域存在的卡的数量，并将手牌数与魔陷区卡数相加，判断总和是否为0，即确认自己手卡和魔法与陷阱区域都没有卡存在。
		+Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)==0
end
