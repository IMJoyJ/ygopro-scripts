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
-- 判断自己手卡与魔法陷阱区域是否均无卡片
function c51838385.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取自己手卡数量
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		-- 加上自己魔法陷阱区数量是否为0
		+Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)==0
end
