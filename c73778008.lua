--深海の怒り
-- 效果：
-- 这张卡的攻击力·守备力上升自己墓地存在的鱼族·海龙族·水族怪兽数量×500的数值。
function c73778008.initial_effect(c)
	-- 这张卡的攻击力·守备力上升自己墓地存在的鱼族·海龙族·水族怪兽数量×500的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c73778008.atkup)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
-- 定义计算攻击力·守备力上升数值的函数
function c73778008.atkup(e,c)
	-- 获取自己墓地中鱼族、海龙族、水族怪兽的数量并乘以500作为上升数值
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_FISH+RACE_SEASERPENT+RACE_AQUA)*500
end
