--メカニカル・ハウンド
-- 效果：
-- 只要自己手卡数目是0张，对方不能发动魔法卡。
function c22512237.initial_effect(c)
	-- 只要自己手卡数目是0张，对方不能发动魔法卡。
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
-- 定义条件函数：该永续效果仅在效果持有者手卡数为0时才适用。
function c22512237.condition(e)
	-- 获取效果持有者当前手卡数量，并判断是否为0。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
-- 定义禁止效果判定函数：对方发动的效果若属于魔法卡的发动且为魔法卡类型，则返回true以禁止发动。
function c22512237.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
