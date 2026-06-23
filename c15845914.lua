--結束と絆の魔導師
-- 效果：
-- 这张卡不能通常召唤。自己墓地有卡25张以上存在的场合才能特殊召唤。
-- ①：只要对方墓地有卡25张以上存在，这张卡的攻击力·守备力上升2500。
local s,id,o=GetID()
-- 初始化卡片效果，设置苏生限制并注册多个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己墓地有卡25张以上存在的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己墓地有卡25张以上存在的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
	-- 只要对方墓地有卡25张以上存在，这张卡的攻击力·守备力上升2500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(2500)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
-- 检查特殊召唤条件，确保手牌玩家墓地有25张以上卡片且场上存在空位
function s.condition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 场上存在空位且手牌玩家墓地有25张以上卡片
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)>=25
end
-- 检查攻击力上升条件，确保对方墓地有25张以上卡片
function s.atkcon(e)
	-- 对方墓地有25张以上卡片
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_GRAVE)>=25
end
