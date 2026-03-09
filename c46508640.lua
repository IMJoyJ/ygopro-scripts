--龍脈に棲む者
-- 效果：
-- ①：这张卡的攻击力上升自己的魔法与陷阱区域的永续魔法卡数量×300。
function c46508640.initial_effect(c)
	-- 效果原文内容：①：这张卡的攻击力上升自己的魔法与陷阱区域的永续魔法卡数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c46508640.atkval)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选表侧表示的永续魔法卡（不包括场地魔法），用于计算攻击力提升值。
function c46508640.cfilter(c)
	return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:GetSequence()~=5
end
-- 计算效果值，返回己方魔法与陷阱区域中满足条件的永续魔法卡数量乘以300作为攻击力上升值。
function c46508640.atkval(e,c)
	-- 检索满足条件的卡片组数量并乘以300，作为该卡攻击力的增加量。
	return Duel.GetMatchingGroupCount(c46508640.cfilter,c:GetControler(),LOCATION_SZONE,0,nil)*300
end
