--スピアフィッシュソルジャー
-- 效果：
-- 这张卡的攻击力上升从游戏中除外的自己的鱼族·海龙族·水族怪兽数量×100的数值。
function c84569017.initial_effect(c)
	-- 这张卡的攻击力上升从游戏中除外的自己的鱼族·海龙族·水族怪兽数量×100的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c84569017.atkup)
	c:RegisterEffect(e1)
end
-- 过滤除外区表侧表示的鱼族、水族或海龙族怪兽
function c84569017.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT)
end
-- 计算攻击力上升值的回调函数
function c84569017.atkup(e,c)
	-- 获取自己除外区满足条件的卡片数量并乘以100作为攻击力上升值
	return Duel.GetMatchingGroupCount(c84569017.atkfilter,c:GetControler(),LOCATION_REMOVED,0,nil)*100
end
