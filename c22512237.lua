--メカニカル・ハウンド
-- 效果：
-- 只要自己手卡数目是0张，对方不能发动魔法卡。
function c22512237.initial_effect(c)
	-- 创建一个场地区域效果，使对方不能发动魔法卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c22512237.aclimit)
	e1:SetCondition(c22512237.condition)
	c:RegisterEffect(e1)
end
-- 条件函数：判断自己手卡数量是否为0
function c22512237.condition(e)
	-- 检索自己手卡数量并判断是否为0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
-- 限制函数：判断效果是否为魔法卡的发动
function c22512237.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
